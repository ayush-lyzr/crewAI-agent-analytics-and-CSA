"""A2A Server for CrewAI Agent.

This is the main entry point for the A2A server that exposes
the CrewAI agent through the A2A protocol.
"""

import logging
import os
import click
import uvicorn
from dotenv import load_dotenv

from a2a.server.apps import A2AStarletteApplication
from a2a.server.request_handlers import DefaultRequestHandler
from a2a.server.tasks import InMemoryTaskStore
from a2a.types import (
    AgentCapabilities,
    AgentCard,
    AgentSkill,
)
from app.agent_executor import CrewAIAgentExecutor

# Load environment variables
load_dotenv()

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)
logger = logging.getLogger(__name__)

# Enable detailed logging for A2A components
logging.getLogger('a2a').setLevel(logging.INFO)
logging.getLogger('app.agent_executor').setLevel(logging.INFO)
logging.getLogger('app.crew').setLevel(logging.INFO)


@click.command()
@click.option('--host', 'host', default='localhost', help='Host to bind the server to')
@click.option('--port', 'port', default=10001, help='Port to bind the server to')
def main(host, port):
    """Entry point for the A2A + CrewAI Agent server."""
    try:
        # Define agent skill
        skill = AgentSkill(
            id='payments_intelligence',
            name='Payments_PoP_Intelligence',
            description=(
                'Enterprise-grade financial intelligence agent for payments, Proof of Payment (PoP), '
                'invoice status, HITL, and analytics. Answers questions about transaction status, '
                'PoP validation, HITL reviews, payment analytics, aggregates, trends, and filtered '
                'invoice listings. Always uses real API data - never hallucinates.'
            ),
            tags=[
                'payments', 'pop', 'invoices', 'analytics', 'hitl',
                'transaction status', 'audit', 'compliance', 'finance'
            ],
            examples=[
                'How many invoices were rejected last month?',
                'Show me pending PoP reviews received via WhatsApp',
                'List all invoices that require human intervention',
                'What are the HITL reasons for rejected payments?',
                'Get analytics for payments in the last quarter'
            ],
        )

        # Determine agent host URL
        # Use HOST_OVERRIDE if set, otherwise use localhost for URL (even if binding to 0.0.0.0)
        if os.getenv('HOST_OVERRIDE'):
            agent_host_url = os.getenv('HOST_OVERRIDE')
            # Ensure URL ends with / if not already
            if not agent_host_url.endswith('/'):
                agent_host_url = agent_host_url + '/'
        elif host == '0.0.0.0':
            # If binding to 0.0.0.0, use localhost in the agent card URL for accessibility
            agent_host_url = f'http://localhost:{port}/'
            logger.warning(f'Binding to 0.0.0.0 but using localhost in agent card URL. '
                         f'For external access, set HOST_OVERRIDE environment variable.')
        else:
            agent_host_url = f'http://{host}:{port}/'

        # Create agent card
        agent_card = AgentCard(
            name='Payments_PoP_Intelligence_Agent',
            description=(
                'Enterprise-grade financial intelligence agent for payments, Proof of Payment (PoP), '
                'invoice status, HITL, and analytics. Answers questions about transaction status, '
                'PoP validation, HITL reviews, payment analytics, aggregates, trends, and filtered '
                'invoice listings. Always uses real API data - never hallucinates.'
            ),
            url=agent_host_url,
            version='1.0.0',
            default_input_modes=['text', 'text/plain'],
            default_output_modes=['text', 'text/plain'],
            capabilities=AgentCapabilities(streaming=False),
            skills=[skill],
        )

        # Create request handler with agent executor
        request_handler = DefaultRequestHandler(
            agent_executor=CrewAIAgentExecutor(),
            task_store=InMemoryTaskStore(),
        )

        # Create and start A2A server
        server = A2AStarletteApplication(
            agent_card=agent_card,
            http_handler=request_handler,
        )

        logger.info(f'Starting A2A server on {host}:{port}')
        logger.info(f'Agent card available at {agent_host_url}.well-known/agent-card.json')
        logger.info('Server is ready to accept connections')

        uvicorn.run(
            server.build(),
            host=host,
            port=port,
            log_level='info',
            access_log=True,
            log_config=None  # Use our custom logging
        )

    except Exception as e:
        logger.error(f'An error occurred during server startup: {e}')
        exit(1)


if __name__ == '__main__':
    main()


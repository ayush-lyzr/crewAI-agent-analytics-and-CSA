"""A2A Agent Executor for CrewAI Agent.

This module provides the A2A protocol integration for the CrewAI agent.
It handles incoming requests and executes the agent, returning results
in the A2A protocol format.
"""

import logging
import asyncio
from a2a.server.agent_execution import AgentExecutor, RequestContext
from a2a.server.events import EventQueue
from a2a.types import (
    InvalidParamsError,
    TextPart,
    UnsupportedOperationError,
)
from a2a.utils import (
    completed_task,
    new_artifact,
    new_agent_text_message,
)
from a2a.utils.errors import ServerError
from app.crew import run_agent

logger = logging.getLogger(__name__)


class CrewAIAgentExecutor(AgentExecutor):
    """A2A Agent Executor for CrewAI Agent."""

    async def execute(
        self,
        context: RequestContext,
        event_queue: EventQueue,
    ) -> None:
        """Execute the agent with the given context."""
        logger.info("=" * 60)
        logger.info(f"🚀 NEW REQUEST RECEIVED")
        logger.info(f"Task ID: {context.task_id}")
        logger.info(f"Context ID: {context.context_id}")
        logger.info(f"Message ID: {context.message.id if hasattr(context.message, 'id') else 'N/A'}")

        # Extract user input from the request
        user_input = context.get_user_input()
        logger.info(f"User input: {user_input[:200] if user_input else 'None'}...")
        logger.info("=" * 60)

        if not user_input or not user_input.strip():
            logger.error("Empty query received")
            raise ServerError(error=InvalidParamsError("Query cannot be empty"))

        try:
            logger.info("Executing CrewAI agent...")

            # Execute the CrewAI agent in a thread pool to avoid blocking
            loop = asyncio.get_event_loop()
            result = await loop.run_in_executor(None, run_agent, user_input)
            logger.info(f"Agent execution completed. Result length: {len(str(result))} characters")

            # Create text part with the result
            parts = [
                TextPart(text=str(result))
            ]

            # Enqueue the completed task event with the result
            logger.info(f"Sending response for task {context.task_id}")
            await event_queue.enqueue_event(
                completed_task(
                    context.task_id,
                    context.context_id,
                    [new_artifact(parts, f'response_{context.task_id}')],
                    [context.message],
                )
            )
            logger.info(f"Successfully completed task {context.task_id}")
        except Exception as e:
            logger.error(f"Error executing agent: {type(e).__name__}: {str(e)}", exc_info=True)
            raise ServerError(
                error=ValueError(f'Error executing agent: {e}')
            ) from e

    async def cancel(
        self, context: RequestContext, event_queue: EventQueue
    ) -> None:
        """Cancel operation is not supported."""
        raise ServerError(error=UnsupportedOperationError())


from crewai import Task, Crew
from app.agent import get_agent

def run_agent(query: str) -> str:
    """
    Execute the payments intelligence agent with the given query.

    The agent will intelligently determine whether to use analytics or PoP query tools
    based on the user's question.
    """
    import logging
    logger = logging.getLogger(__name__)

    agent = get_agent()

    # Log all tools before creating task/crew
    logger.info(f"Agent created with {len(agent.tools)} tools:")
    for i, tool in enumerate(agent.tools):
        tool_name = tool.name if hasattr(tool, 'name') else str(tool)
        logger.info(f"  Tool {i}: '{tool_name}'")

    task = Task(
        description=(
            f"User query: {query}\n\n"
            "Step 1: Analyze the query to determine if it's asking for:\n"
            "  - Analytics/aggregates/trends/summaries → Use payments_analytics_tool\n"
            "  - Specific invoices/PoP/status/filtered listings → Use payments_pop_query_tool\n\n"
            "Step 2: Call the appropriate tool(s) with the correct parameters.\n"
            "Step 3: Summarize the result clearly and accurately for a business user.\n"
            "Step 4: If the query mentions specific filters (vendor, order, status, "
            "channel, dates, HITL), extract them and pass to the PoP query tool.\n\n"
            "Important: Never make up data. Always use the API tools to get real data."
        ),
        expected_output=(
            "A clear, accurate, and business-friendly answer based on real API data. "
            "Include relevant numbers, statuses, and insights from the API response."
        ),
        agent=agent
    )

    crew = Crew(
        agents=[agent],
        tasks=[task],
        process="sequential",
        verbose=True
    )

    result = crew.kickoff()
    return str(result)


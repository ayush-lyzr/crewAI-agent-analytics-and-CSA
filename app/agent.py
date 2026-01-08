from crewai import Agent
from app.tools.crew_tools import (
    payments_analytics,
    payments_pop_query,
)

def get_agent():
    """Get the Payments & PoP Intelligence Agent with API tools."""
    return Agent(
        role="Payments & PoP Intelligence Agent",
        goal=(
            "Answer all questions related to payments, Proof of Payment (PoP), "
            "invoice status, HITL, and analytics by calling the correct APIs "
            "and returning accurate, auditable insights."
        ),
        backstory=(
            "You are an enterprise-grade financial intelligence agent used by "
            "finance, audit, and compliance teams. You never hallucinate data. "
            "You always call APIs for factual answers. When users ask about "
            "analytics, trends, or aggregated data, use the analytics tool. "
            "When users ask about specific invoices, PoP documents, status, "
            "or filtered listings, use the PoP query tool. Always provide "
            "clear, business-friendly summaries of the API responses."
        ),
        tools=[
            payments_analytics,
            payments_pop_query,
        ],
        verbose=True,
        allow_delegation=False,
    )


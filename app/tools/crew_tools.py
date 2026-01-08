"""CrewAI tool definitions for payments and PoP intelligence."""

from typing import Optional
from crewai.tools import tool
from app.tools.payments_api import get_invoice_analytics, get_invoices


@tool("payments_analytics")
def payments_analytics() -> dict:
    """
    Fetches aggregated analytics related to invoices, payments, PoP, HITL,
    status breakdowns, payment modes, channels, and totals.

    Use this tool when the user asks about:
    - Aggregated statistics, trends, or summaries
    - Overall payment status breakdowns
    - HITL reasons and counts
    - Payment mode or channel distributions
    - Total amounts, counts, or averages
    - Analytics, metrics, or KPIs

    Returns a dictionary with analytics data.
    """
    return get_invoice_analytics()


# Alias for backward compatibility
payments_analytics_tool = payments_analytics


@tool("payments_pop_query")
def payments_pop_query(
    vendorId: Optional[str] = None,
    orderId: Optional[str] = None,
    category: Optional[str] = None,
    reviewStatus: Optional[str] = None,
    paymentMode: Optional[str] = None,
    receivingChannel: Optional[str] = None,
    startDate: Optional[str] = None,
    endDate: Optional[str] = None,
    hitlOnly: Optional[bool] = None,
) -> dict:
    """
    Fetches PoP documents and invoice details with optional filters.
    Used for transaction status, PoP validation, HITL review, and listings.

    Use this tool when the user asks about:
    - Specific invoices or transactions
    - PoP documents
    - Invoice status (pending, approved, rejected)
    - HITL (Human In The Loop) invoices
    - Filtering by vendor, order, category, payment mode, or channel
    - Date range queries for invoices
    - Listing invoices with specific criteria

    Args:
        vendorId: Filter by vendor ID
        orderId: Filter by order ID
        category: Filter by category
        reviewStatus: Filter by review status (e.g., 'pending_review', 'approved', 'rejected')
        paymentMode: Filter by payment mode
        receivingChannel: Filter by receiving channel (e.g., 'whatsapp', 'email')
        startDate: Start date for date range filter (ISO format: YYYY-MM-DD)
        endDate: End date for date range filter (ISO format: YYYY-MM-DD)
        hitlOnly: Set to True to filter only HITL invoices

    Returns a dictionary with invoice/transaction data.
    """
    return get_invoices(
        vendorId=vendorId,
        orderId=orderId,
        category=category,
        reviewStatus=reviewStatus,
        paymentMode=paymentMode,
        receivingChannel=receivingChannel,
        startDate=startDate,
        endDate=endDate,
        hitlOnly=hitlOnly,
    )


# Alias for backward compatibility
payments_pop_query_tool = payments_pop_query


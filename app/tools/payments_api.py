"""Payments API client for fetching analytics and invoice data."""

import os
import requests
from typing import Optional, Dict, Any
from dotenv import load_dotenv

load_dotenv()

BASE_URL = os.getenv("PAYMENTS_API_BASE_URL", "")

if not BASE_URL:
    raise ValueError(
        "PAYMENTS_API_BASE_URL not set in .env file. "
        "Please add: PAYMENTS_API_BASE_URL=https://your-ngrok-url.ngrok-free.app"
    )


def get_invoice_analytics() -> Dict[str, Any]:
    """
    Calls Analytics API
    GET /api/invoices/analytics

    Returns aggregated analytics related to invoices, payments, PoP, HITL,
    status breakdowns, payment modes, channels, and totals.
    """
    url = f"{BASE_URL}/api/invoices/analytics"
    try:
        response = requests.get(url, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise Exception(f"Failed to fetch analytics: {str(e)}")


def get_invoices(
    vendorId: Optional[str] = None,
    orderId: Optional[str] = None,
    category: Optional[str] = None,
    reviewStatus: Optional[str] = None,
    paymentMode: Optional[str] = None,
    receivingChannel: Optional[str] = None,
    startDate: Optional[str] = None,
    endDate: Optional[str] = None,
    hitlOnly: Optional[bool] = None,
) -> Dict[str, Any]:
    """
    Calls PoP / Invoices API
    GET /api/invoices

    Fetches PoP documents and invoice details with optional filters.
    Used for transaction status, PoP validation, HITL review, and listings.

    Args:
        vendorId: Filter by vendor ID
        orderId: Filter by order ID
        category: Filter by category
        reviewStatus: Filter by review status (e.g., 'pending_review', 'approved', 'rejected')
        paymentMode: Filter by payment mode
        receivingChannel: Filter by receiving channel (e.g., 'whatsapp', 'email')
        startDate: Start date for date range filter (ISO format)
        endDate: End date for date range filter (ISO format)
        hitlOnly: Filter to only HITL (Human In The Loop) invoices
    """
    url = f"{BASE_URL}/api/invoices"

    params = {
        "vendorId": vendorId,
        "orderId": orderId,
        "category": category,
        "reviewStatus": reviewStatus,
        "paymentMode": paymentMode,
        "receivingChannel": receivingChannel,
        "startDate": startDate,
        "endDate": endDate,
        "hitlOnly": hitlOnly,
    }

    # Remove None values
    params = {k: v for k, v in params.items() if v is not None}

    try:
        response = requests.get(url, params=params, timeout=10)
        response.raise_for_status()
        return response.json()
    except requests.exceptions.RequestException as e:
        raise Exception(f"Failed to fetch invoices: {str(e)}")


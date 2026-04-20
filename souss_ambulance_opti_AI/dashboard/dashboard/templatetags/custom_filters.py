from django import template

register = template.Library()

@register.filter
def percentage(value, total):
    """Calculate percentage safely"""
    try:
        value = float(value or 0)
        total = float(total or 0)
        if total == 0:
            return 0
        return int((value / total) * 100)
    except (ValueError, TypeError, ZeroDivisionError):
        return 0

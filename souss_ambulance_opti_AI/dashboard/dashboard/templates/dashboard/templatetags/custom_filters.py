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

@register.filter
def mul(value, arg):
    """Multiply value by arg"""
    try:
        return float(value or 0) * float(arg or 0)
    except (ValueError, TypeError):
        return 0
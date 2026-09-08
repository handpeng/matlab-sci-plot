"""Contract-first scientific figure planning primitives."""

__version__ = "1.2.0"

from .contracts import ContractError, validate_contract
from .registry import Registry

__all__ = ["ContractError", "Registry", "validate_contract", "__version__"]

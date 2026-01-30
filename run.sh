#!/bin/bash
#==============================================================================
# Run Script for Financial Backend API
# Like running MQL5 EA in MetaTrader
#==============================================================================

echo "🚀 Starting Financial Backend API..."
echo ""

# Use the correct Python installation
PYTHON_PATH="/Library/Frameworks/Python.framework/Versions/3.13/bin/python3"

# Check if Python exists
if [ ! -f "$PYTHON_PATH" ]; then
    echo "❌ Python not found at $PYTHON_PATH"
    echo "Using system python3..."
    PYTHON_PATH="python3"
fi

# Run the application
$PYTHON_PATH app.py

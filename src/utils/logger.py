#==============================================================================
# Logger Utility
# Like MQL5 Print() and Comment() - Centralized logging
#==============================================================================

import logging
from datetime import datetime


class AppLogger:
    """
    Application logger
    Like Print() and Comment() functions in MQL5
    """
    
    @staticmethod
    def setup_logger(name: str = "financial-backend") -> logging.Logger:
        """
        Setup and configure logger
        
        Args:
            name: Logger name
            
        Returns:
            Configured logger instance
        """
        logger = logging.getLogger(name)
        logger.setLevel(logging.INFO)
        
        # Console handler
        console_handler = logging.StreamHandler()
        console_handler.setLevel(logging.INFO)
        
        # Formatter (like MQL5 timestamp format)
        formatter = logging.Formatter(
            '%(asctime)s - [%(levelname)s] - %(message)s',
            datefmt='%Y.%m.%d %H:%M:%S'
        )
        console_handler.setFormatter(formatter)
        
        logger.addHandler(console_handler)
        
        return logger
    
    
    @staticmethod
    def log_startup(logger: logging.Logger, config: dict):
        """
        Log startup information
        Like OnInit() startup logs in MQL5
        
        Args:
            logger: Logger instance
            config: Configuration dict
        """
        logger.info("=" * 80)
        logger.info("Financial Backend API Starting...")
        logger.info("=" * 80)
        for key, value in config.items():
            # Mask sensitive data
            if "TOKEN" in key or "PASSWORD" in key:
                value = "***" if value else "NOT SET"
            logger.info(f"{key}: {value}")
        logger.info("=" * 80)
    
    
    @staticmethod
    def log_shutdown(logger: logging.Logger):
        """
        Log shutdown information
        Like OnDeinit() logs in MQL5
        
        Args:
            logger: Logger instance
        """
        logger.info("=" * 80)
        logger.info("Financial Backend API Shutting Down...")
        logger.info("=" * 80)


# Initialize default logger
logger = AppLogger.setup_logger()

-- Create DB, Schema, and Warehouse
CREATE DATABASE IF NOT EXISTS SUMMIT_AI_OBS_DEMO;
CREATE SCHEMA IF NOT EXISTS DATA;
CREATE WAREHOUSE IF NOT EXISTS AI_OBS_WAREHOUSE WITH WAREHOUSE_SIZE='SMALL';

--Create Stage
CREATE STAGE IF NOT EXISTS DOCS ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE' ) DIRECTORY = ( ENABLE = TRUE);
 
--Create network rule and api integration to install packages from pypi
CREATE OR REPLACE NETWORK RULE snowflake_docs_network_rule
 MODE = EGRESS
 TYPE = HOST_PORT
 VALUE_LIST = ('docs.snowflake.com');

  -- Create external access integration on top of network rule for pypi access
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION snowflake_docs_EAI
 ALLOWED_NETWORK_RULES = (snowflake_docs_network_rule)
 ENABLED = true;

-- Create an API integration with Github
CREATE OR REPLACE API INTEGRATION GIT_INTEGRATION_SUMMIT_AI_OBS_DEMO
   api_provider = git_https_api
  api_allowed_prefixes = ('https://github.com/sfc-gh-ebotwick')
   enabled = true
   comment='Git integration with AI Observability Summit Demo Repo';

-- Create the integration with the Github demo repository
CREATE OR REPLACE GIT REPOSITORY SUMMIT_AI_OBS_DEMO_GIT_REPO
   ORIGIN = 'https://github.com/sfc-gh-ebotwick/summit_demo_ai_obs' 
   API_INTEGRATION = 'GIT_INTEGRATION_SUMMIT_AI_OBS_DEMO' 
   COMMENT = 'Github Repository ';

-- Fetch most recent files from Github repository
ALTER GIT REPOSITORY SUMMIT_AI_OBS_DEMO_GIT_REPO FETCH;

-- Copy Cortex Search Setup notebook into snowflake configure runtime settings
CREATE OR REPLACE NOTEBOOK SUMMIT_AI_OBS_DEMO.DATA.SETUP_CORTEX_SEARCH_SERVICE
FROM '@SUMMIT_AI_OBS_DEMO.DATA.SUMMIT_AI_OBS_DEMO_GIT_REPO/branches/main/' 
MAIN_FILE = 'CORTEX_SEARCH_SETUP.ipynb' QUERY_WAREHOUSE = AI_OBS_WAREHOUSE
IDLE_AUTO_SHUTDOWN_TIME_SECONDS = 3600;

-- Copy AI Obs notebook into snowflake configure runtime settings
CREATE OR REPLACE NOTEBOOK SUMMIT_AI_OBS_DEMO.DATA.AI_AGENT_OBSERVABILITY
FROM '@SUMMIT_AI_OBS_DEMO.DATA.SUMMIT_AI_OBS_DEMO_GIT_REPO/branches/main/' 
MAIN_FILE = 'AI_AGENT_OBSERVABILITY.ipynb' QUERY_WAREHOUSE = AI_OBS_WAREHOUSE
IDLE_AUTO_SHUTDOWN_TIME_SECONDS = 3600;

-- Enable external access integration for web search tool in AI Agent Noteobok
alter NOTEBOOK SUMMIT_AI_OBS_DEMO.DATA.AI_AGENT_OBSERVABILITY set EXTERNAL_ACCESS_INTEGRATIONS = ( 'snowflake_docs_EAI' )

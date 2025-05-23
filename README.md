# AI Observability Demo for Snowflake Summit 2025

## In this demo repo we will explore the following

### SUMMIT_DEMO_CORTEX_SEARCH.ipynb
 - Parse PDF documents containing Snowflake blog posts into markdown text and split text on paragraph seperator
 - Use Snowflake Cortex to classify each text chunk as one of the following categories [Customer Reference, Code Example, Benchmark, Technical Blog]
 - Index chunked text (with document titles and classifications appended) into vectors for retreival with Cortex Search Service

### SUMMIT_DEMO_AI_AGENT_OBSERVABILITY.ipynb
 - Test out Cortex Search Service and experiment with confidence score thresholds
 - Define web search agent to retrieve context from docs.snowflake.com when local results are not relevant
 - Set up class with various agents and instrument for Evaluation and Tracing in Snowflake AI Observability
 - Instantiate multiple versions of the class for A/B testing
 - Pass prompts to applications


### Snowflake AI Observability UI
- Review and compare each application side-by-side to better understand
  - Model Quality
  - Retrieval Quality
  - Latency
  - Cost
- Consider which application would be the best candidate for production based on insights


SETUP INSTRUCTIONS

```
-- Create DB, Schema, and Warehouse
CREATE DATABASE IF NOT EXISTS SUMMIT_AI_OBS_DEMO;
CREATE SCHEMA IF NOT EXISTS DATA;
CREATE WAREHOUSE IF NOT EXISTS AI_OBS_WAREHOUSE WITH WAREHOUSE_SIZE='SMALL';

--Create Stage
CREATE STAGE IF NOT EXISTS DOCS ENCRYPTION = (TYPE = 'SNOWFLAKE_SSE' ) DIRECTORY = ( ENABLE = TRUE);
 
--Create network rule and api integration to pull data from docs.snowflake.com
CREATE OR REPLACE NETWORK RULE snowflake_docs_network_rule
 MODE = EGRESS
 TYPE = HOST_PORT
 VALUE_LIST = ('docs.snowflake.com');

  -- Create external access integration on top of network rule for snowflake docs web access
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

```




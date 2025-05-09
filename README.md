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
 - Pass prompts to applications and review cost/latency/quality of each application side-by-side


SETUP INSTRUCTIONS

```
CREATE DATABASE IF NOT EXISTS SUMMIT_25_AI_OBS_DEMO;
CREATE SCHEMA IF NOT EXISTS DATA;

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

```




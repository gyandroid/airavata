/*
 *
 * Licensed to the Apache Software Foundation (ASF) under one
 * or more contributor license agreements.  See the NOTICE file
 * distributed with this work for additional information
 * regarding copyright ownership.  The ASF licenses this file
 * to you under the Apache License, Version 2.0 (the
 * "License"); you may not use this file except in compliance
 * with the License.  You may obtain a copy of the License at
 *
 *   http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing,
 * software distributed under the License is distributed on an
 * "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 * KIND, either express or implied.  See the License for the
 * specific language governing permissions and limitations
 * under the License.
 *
 */
CREATE TABLE GATEWAY
(
        GATEWAY_NAME VARCHAR(255),
	      OWNER VARCHAR(255),
        PRIMARY KEY (GATEWAY_NAME)
);

CREATE TABLE CONFIGURATION
(
        CONFIG_KEY VARCHAR(255),
        CONFIG_VAL VARCHAR(255),
        EXPIRE_DATE TIMESTAMP DEFAULT '0000-00-00 00:00:00',
        CATEGORY_ID VARCHAR (255),
        PRIMARY KEY(CONFIG_KEY, CONFIG_VAL, CATEGORY_ID)
);

INSERT INTO CONFIGURATION (CONFIG_KEY, CONFIG_VAL, EXPIRE_DATE, CATEGORY_ID) VALUES('registry.version', '0.12', CURRENT_TIMESTAMP ,'SYSTEM');

CREATE TABLE USERS
(
        USER_NAME VARCHAR(255),
        PASSWORD VARCHAR(255),
        PRIMARY KEY(USER_NAME)
);

CREATE TABLE GATEWAY_WORKER
(
        GATEWAY_NAME VARCHAR(255),
        USER_NAME VARCHAR(255),
        PRIMARY KEY (GATEWAY_NAME, USER_NAME),
        FOREIGN KEY (GATEWAY_NAME) REFERENCES GATEWAY(GATEWAY_NAME) ON DELETE CASCADE,
        FOREIGN KEY (USER_NAME) REFERENCES USERS(USER_NAME) ON DELETE CASCADE
);

CREATE TABLE PROJECT
(
         GATEWAY_NAME VARCHAR(255),
         USER_NAME VARCHAR(255),
         PROJECT_NAME VARCHAR(255) NOT NULL,
         PROJECT_ID VARCHAR(255),
         DESCRIPTION VARCHAR(255),
         CREATION_TIME TIMESTAMP DEFAULT NOW(),
         PRIMARY KEY (PROJECT_ID),
         FOREIGN KEY (GATEWAY_NAME) REFERENCES GATEWAY(GATEWAY_NAME) ON DELETE CASCADE,
         FOREIGN KEY (USER_NAME) REFERENCES USERS(USER_NAME) ON DELETE CASCADE
);

CREATE TABLE PROJECT_USER
(
    PROJECT_ID VARCHAR(255),
    USER_NAME VARCHAR(255),
    PRIMARY KEY (PROJECT_ID,USER_NAME),
    FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT(PROJECT_ID) ON DELETE CASCADE,
    FOREIGN KEY (USER_NAME) REFERENCES USERS(USER_NAME) ON DELETE CASCADE
);

CREATE TABLE PUBLISHED_WORKFLOW
(
         GATEWAY_NAME VARCHAR(255),
         CREATED_USER VARCHAR(255),
         PUBLISH_WORKFLOW_NAME VARCHAR(255),
         VERSION VARCHAR(255),
         PUBLISHED_DATE TIMESTAMP DEFAULT '0000-00-00 00:00:00',
         PATH VARCHAR (255),
         WORKFLOW_CONTENT BLOB,
         PRIMARY KEY(GATEWAY_NAME, PUBLISH_WORKFLOW_NAME),
         FOREIGN KEY (GATEWAY_NAME) REFERENCES GATEWAY(GATEWAY_NAME) ON DELETE CASCADE,
         FOREIGN KEY (CREATED_USER) REFERENCES USERS(USER_NAME) ON DELETE CASCADE
);

CREATE TABLE USER_WORKFLOW
(
         GATEWAY_NAME VARCHAR(255),
         OWNER VARCHAR(255),
         TEMPLATE_NAME VARCHAR(255),
         LAST_UPDATED_TIME TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
         PATH VARCHAR (255),
         WORKFLOW_GRAPH BLOB,
         PRIMARY KEY(GATEWAY_NAME, OWNER, TEMPLATE_NAME),
         FOREIGN KEY (GATEWAY_NAME) REFERENCES GATEWAY(GATEWAY_NAME) ON DELETE CASCADE,
         FOREIGN KEY (OWNER) REFERENCES USERS(USER_NAME) ON DELETE CASCADE
);

CREATE TABLE EXPERIMENT
(
        EXPERIMENT_ID VARCHAR(255),
        GATEWAY_NAME VARCHAR(255),
        EXECUTION_USER VARCHAR(255) NOT NULL,
        PROJECT_ID VARCHAR(255) NOT NULL,
        CREATION_TIME TIMESTAMP DEFAULT NOW(),
        EXPERIMENT_NAME VARCHAR(255) NOT NULL,
        EXPERIMENT_DESCRIPTION VARCHAR(255),
        APPLICATION_ID VARCHAR(255),
        APPLICATION_VERSION VARCHAR(255),
        WORKFLOW_TEMPLATE_ID VARCHAR(255),
        WORKFLOW_TEMPLATE_VERSION VARCHAR(255),
        WORKFLOW_EXECUTION_ID VARCHAR(255),
        ALLOW_NOTIFICATION SMALLINT,
        PRIMARY KEY(EXPERIMENT_ID),
        FOREIGN KEY (GATEWAY_NAME) REFERENCES GATEWAY(GATEWAY_NAME) ON DELETE CASCADE,
        FOREIGN KEY (EXECUTION_USER) REFERENCES USERS(USER_NAME) ON DELETE CASCADE,
        FOREIGN KEY (PROJECT_ID) REFERENCES PROJECT(PROJECT_ID) ON DELETE CASCADE
);

CREATE TABLE EXPERIMENT_INPUT
(
        EXPERIMENT_ID VARCHAR(255),
        INPUT_KEY VARCHAR(255) NOT NULL,
        DATA_TYPE VARCHAR(255),
        APP_ARGUMENT VARCHAR(255),
        STANDARD_INPUT SMALLINT,
        USER_FRIENDLY_DESC VARCHAR(255),
        METADATA VARCHAR(255),
        VALUE LONGTEXT,
        INPUT_ORDER INTEGER,
        IS_REQUIRED SMALLINT,
        REQUIRED_TO_COMMANDLINE SMALLINT,
        DATA_STAGED SMALLINT,
        PRIMARY KEY(EXPERIMENT_ID,INPUT_KEY),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE
);

CREATE TABLE EXPERIMENT_OUTPUT
(
        EXPERIMENT_ID VARCHAR(255),
        OUTPUT_KEY VARCHAR(255) NOT NULL,
        DATA_TYPE VARCHAR(255),
        VALUE LONGTEXT,
        IS_REQUIRED SMALLINT,
        REQUIRED_TO_COMMANDLINE SMALLINT,
        DATA_MOVEMENT SMALLINT,
        DATA_NAME_LOCATION VARCHAR(255),
        SEARCH_QUERY VARCHAR(255),
        APP_ARGUMENT VARCHAR(255),
        PRIMARY KEY(EXPERIMENT_ID,OUTPUT_KEY),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE
);

CREATE TABLE WORKFLOW_NODE_DETAIL
(
        EXPERIMENT_ID VARCHAR(255) NOT NULL,
        NODE_INSTANCE_ID VARCHAR(255),
        CREATION_TIME TIMESTAMP DEFAULT NOW(),
        NODE_NAME VARCHAR(255) NOT NULL,
        EXECUTION_UNIT VARCHAR(255) NOT NULL,
        EXECUTION_UNIT_DATA VARCHAR(255),
        PRIMARY KEY(NODE_INSTANCE_ID),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE
);

CREATE TABLE TASK_DETAIL
(
        TASK_ID VARCHAR(255),
        NODE_INSTANCE_ID VARCHAR(255),
        CREATION_TIME TIMESTAMP DEFAULT NOW(),
        APPLICATION_ID VARCHAR(255),
        APPLICATION_VERSION VARCHAR(255),
        APPLICATION_DEPLOYMENT_ID VARCHAR(255),
        ALLOW_NOTIFICATION SMALLINT,
        PRIMARY KEY(TASK_ID),
        FOREIGN KEY (NODE_INSTANCE_ID) REFERENCES WORKFLOW_NODE_DETAIL(NODE_INSTANCE_ID) ON DELETE CASCADE
);

CREATE TABLE NOTIFICATION_EMAIL
(
  EMAIL_ID INTEGER NOT NULL AUTO_INCREMENT,
  EXPERIMENT_ID VARCHAR(255),
  TASK_ID VARCHAR(255),
  EMAIL_ADDRESS VARCHAR(255),
  PRIMARY KEY(EMAIL_ID),
  FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
  FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE APPLICATION_INPUT
(
        TASK_ID VARCHAR(255),
        INPUT_KEY VARCHAR(255) NOT NULL,
        DATA_TYPE VARCHAR(255),
        APP_ARGUMENT VARCHAR(255),
        STANDARD_INPUT SMALLINT,
        USER_FRIENDLY_DESC VARCHAR(255),
        METADATA VARCHAR(255),
        VALUE LONGTEXT,
        INPUT_ORDER INTEGER,
        IS_REQUIRED SMALLINT,
        REQUIRED_TO_COMMANDLINE SMALLINT,
        DATA_STAGED SMALLINT,
        PRIMARY KEY(TASK_ID,INPUT_KEY),
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE APPLICATION_OUTPUT
(
        TASK_ID VARCHAR(255),
        OUTPUT_KEY VARCHAR(255) NOT NULL,
        DATA_TYPE VARCHAR(255),
        VALUE LONGTEXT,
        DATA_MOVEMENT SMALLINT,
        IS_REQUIRED SMALLINT,
        REQUIRED_TO_COMMANDLINE SMALLINT,
        DATA_NAME_LOCATION VARCHAR(255),
        SEARCH_QUERY VARCHAR(255),
        APP_ARGUMENT VARCHAR(255),
        PRIMARY KEY(TASK_ID,OUTPUT_KEY),
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE NODE_INPUT
(
       NODE_INSTANCE_ID VARCHAR(255),
       INPUT_KEY VARCHAR(255) NOT NULL,
       DATA_TYPE VARCHAR(255),
       APP_ARGUMENT VARCHAR(255),
       STANDARD_INPUT SMALLINT,
       USER_FRIENDLY_DESC VARCHAR(255),
       METADATA VARCHAR(255),
       VALUE VARCHAR(255),
       INPUT_ORDER INTEGER,
       IS_REQUIRED SMALLINT,
       REQUIRED_TO_COMMANDLINE SMALLINT,
       DATA_STAGED SMALLINT,
       PRIMARY KEY(NODE_INSTANCE_ID,INPUT_KEY),
       FOREIGN KEY (NODE_INSTANCE_ID) REFERENCES WORKFLOW_NODE_DETAIL(NODE_INSTANCE_ID) ON DELETE CASCADE
);

CREATE TABLE NODE_OUTPUT
(
       NODE_INSTANCE_ID VARCHAR(255),
       OUTPUT_KEY VARCHAR(255) NOT NULL,
       DATA_TYPE VARCHAR(255),
       VALUE VARCHAR(255),
       IS_REQUIRED SMALLINT,
       REQUIRED_TO_COMMANDLINE SMALLINT,
       DATA_MOVEMENT SMALLINT,
       DATA_NAME_LOCATION VARCHAR(255),
       SEARCH_QUERY VARCHAR(255),
       APP_ARGUMENT VARCHAR(255),
       PRIMARY KEY(NODE_INSTANCE_ID,OUTPUT_KEY),
       FOREIGN KEY (NODE_INSTANCE_ID) REFERENCES WORKFLOW_NODE_DETAIL(NODE_INSTANCE_ID) ON DELETE CASCADE
);

CREATE TABLE JOB_DETAIL
(
        JOB_ID VARCHAR(255),
        TASK_ID VARCHAR(255),
        JOB_DESCRIPTION LONGTEXT NOT NULL,
        CREATION_TIME TIMESTAMP DEFAULT NOW(),
        COMPUTE_RESOURCE_CONSUMED VARCHAR(255),
        PRIMARY KEY (TASK_ID, JOB_ID),
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE DATA_TRANSFER_DETAIL
(
        TRANSFER_ID VARCHAR(255),
        TASK_ID VARCHAR(255),
        CREATION_TIME TIMESTAMP DEFAULT NOW(),
        TRANSFER_DESC VARCHAR(255) NOT NULL,
        PRIMARY KEY(TRANSFER_ID),
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE ERROR_DETAIL
(
         ERROR_ID INTEGER NOT NULL AUTO_INCREMENT,
         EXPERIMENT_ID VARCHAR(255),
         TASK_ID VARCHAR(255),
         NODE_INSTANCE_ID VARCHAR(255),
         JOB_ID VARCHAR(255),
         CREATION_TIME TIMESTAMP DEFAULT NOW(),
         ACTUAL_ERROR_MESSAGE LONGTEXT,
         USER_FRIEDNLY_ERROR_MSG VARCHAR(255),
         TRANSIENT_OR_PERSISTENT SMALLINT,
         ERROR_CATEGORY VARCHAR(255),
         CORRECTIVE_ACTION VARCHAR(255),
         ACTIONABLE_GROUP VARCHAR(255),
         PRIMARY KEY(ERROR_ID),
         FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
         FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE,
         FOREIGN KEY (NODE_INSTANCE_ID) REFERENCES WORKFLOW_NODE_DETAIL(NODE_INSTANCE_ID) ON DELETE CASCADE
);

CREATE TABLE STATUS
(
        STATUS_ID INTEGER NOT NULL AUTO_INCREMENT,
        EXPERIMENT_ID VARCHAR(255),
        NODE_INSTANCE_ID VARCHAR(255),
        TRANSFER_ID VARCHAR(255),
        TASK_ID VARCHAR(255),
        JOB_ID VARCHAR(255),
        STATE VARCHAR(255),
        STATUS_UPDATE_TIME TIMESTAMP DEFAULT '0000-00-00 00:00:00' ON UPDATE now(),
        STATUS_TYPE VARCHAR(255),
        PRIMARY KEY(STATUS_ID),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE,
        FOREIGN KEY (NODE_INSTANCE_ID) REFERENCES WORKFLOW_NODE_DETAIL(NODE_INSTANCE_ID) ON DELETE CASCADE,
        FOREIGN KEY (TRANSFER_ID) REFERENCES DATA_TRANSFER_DETAIL(TRANSFER_ID) ON DELETE CASCADE
);

CREATE TABLE CONFIG_DATA
(
        EXPERIMENT_ID VARCHAR(255),
        AIRAVATA_AUTO_SCHEDULE SMALLINT NOT NULL,
        OVERRIDE_MANUAL_SCHEDULE_PARAMS SMALLINT NOT NULL,
        SHARE_EXPERIMENT SMALLINT,
        PRIMARY KEY(EXPERIMENT_ID),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE

);

CREATE TABLE COMPUTATIONAL_RESOURCE_SCHEDULING
(
        RESOURCE_SCHEDULING_ID INTEGER NOT NULL AUTO_INCREMENT,
        EXPERIMENT_ID VARCHAR(255),
        TASK_ID VARCHAR(255),
        RESOURCE_HOST_ID VARCHAR(255),
        CPU_COUNT INTEGER,
        NODE_COUNT INTEGER,
        NO_OF_THREADS INTEGER,
        QUEUE_NAME VARCHAR(255),
        WALLTIME_LIMIT INTEGER,
        JOB_START_TIME TIMESTAMP DEFAULT '0000-00-00 00:00:00',
        TOTAL_PHYSICAL_MEMORY INTEGER,
        COMPUTATIONAL_PROJECT_ACCOUNT VARCHAR(255),
        PRIMARY KEY(RESOURCE_SCHEDULING_ID),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE ADVANCE_INPUT_DATA_HANDLING
(
       INPUT_DATA_HANDLING_ID INTEGER NOT NULL AUTO_INCREMENT,
       EXPERIMENT_ID VARCHAR(255),
       TASK_ID VARCHAR(255),
       WORKING_DIR_PARENT VARCHAR(255),
       UNIQUE_WORKING_DIR VARCHAR(255),
       STAGE_INPUT_FILES_TO_WORKING_DIR SMALLINT,
       CLEAN_AFTER_JOB SMALLINT,
       PRIMARY KEY(INPUT_DATA_HANDLING_ID),
       FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
       FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE ADVANCE_OUTPUT_DATA_HANDLING
(
       OUTPUT_DATA_HANDLING_ID INTEGER NOT NULL AUTO_INCREMENT,
       EXPERIMENT_ID VARCHAR(255),
       TASK_ID VARCHAR(255),
       OUTPUT_DATA_DIR VARCHAR(255),
       DATA_REG_URL VARCHAR (255),
       PERSIST_OUTPUT_DATA SMALLINT,
       PRIMARY KEY(OUTPUT_DATA_HANDLING_ID),
       FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
       FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE QOS_PARAM
(
        QOS_ID INTEGER NOT NULL AUTO_INCREMENT,
        EXPERIMENT_ID VARCHAR(255),
        TASK_ID VARCHAR(255),
        START_EXECUTION_AT VARCHAR(255),
        EXECUTE_BEFORE VARCHAR(255),
        NO_OF_RETRIES INTEGER,
        PRIMARY KEY(QOS_ID),
        FOREIGN KEY (EXPERIMENT_ID) REFERENCES EXPERIMENT(EXPERIMENT_ID) ON DELETE CASCADE,
        FOREIGN KEY (TASK_ID) REFERENCES TASK_DETAIL(TASK_ID) ON DELETE CASCADE
);

CREATE TABLE COMMUNITY_USER
(
        GATEWAY_NAME VARCHAR(256) NOT NULL,
        COMMUNITY_USER_NAME VARCHAR(256) NOT NULL,
        TOKEN_ID VARCHAR(256) NOT NULL,
        COMMUNITY_USER_EMAIL VARCHAR(256) NOT NULL,
        PRIMARY KEY (GATEWAY_NAME, COMMUNITY_USER_NAME, TOKEN_ID)
);

CREATE TABLE CREDENTIALS
(
        GATEWAY_ID VARCHAR(256) NOT NULL,
        TOKEN_ID VARCHAR(256) NOT NULL,
        CREDENTIAL BLOB NOT NULL,
        PORTAL_USER_ID VARCHAR(256) NOT NULL,
        TIME_PERSISTED TIMESTAMP DEFAULT NOW() ON UPDATE NOW(),
        PRIMARY KEY (GATEWAY_ID, TOKEN_ID)
);



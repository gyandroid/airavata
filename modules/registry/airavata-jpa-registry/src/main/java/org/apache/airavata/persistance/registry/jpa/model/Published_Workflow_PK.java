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

package org.apache.airavata.persistance.registry.jpa.model;

import java.io.Serializable;

public class Published_Workflow_PK implements Serializable {
    private String gateway_name;
    private String publish_workflow_name;

    public Published_Workflow_PK(String gateway_name, String publish_workflow_name) {
        this.gateway_name = gateway_name;
        this.publish_workflow_name = publish_workflow_name;
    }

    public Published_Workflow_PK() {
        ;
    }

    @Override
    public boolean equals(Object o) {
        return false;
    }

    @Override
    public int hashCode() {
        return 1;
    }

    public String getPublish_workflow_name() {
        return publish_workflow_name;
    }

    public void setPublish_workflow_name(String publish_workflow_name) {
        this.publish_workflow_name = publish_workflow_name;
    }

    public String getGateway_name() {
        return gateway_name;
    }

    public void setGateway_name(String gateway_name) {
        this.gateway_name = gateway_name;
    }
}

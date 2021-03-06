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

package org.apache.aiaravata.application.catalog.data.model;

import org.apache.openjpa.persistence.DataCache;

import javax.persistence.*;
import java.io.Serializable;

@DataCache
@Entity
@Table(name = "MODULE_LOAD_CMD")
@IdClass(ModuleLoadCmd_PK.class)
public class ModuleLoadCmd implements Serializable {

    @Id
    @Column(name = "CMD")
    private String cmd;

    @Id
    @Column(name = "APP_DEPLOYMENT_ID")
    private String appDeploymentId;

    @ManyToOne(cascade= CascadeType.MERGE)
    @JoinColumn(name = "APP_DEPLOYMENT_ID")
    private ApplicationDeployment applicationDeployment;

    public String getCmd() {
        return cmd;
    }

    public String getAppDeploymentId() {
        return appDeploymentId;
    }

    public ApplicationDeployment getApplicationDeployment() {
        return applicationDeployment;
    }

    public void setCmd(String cmd) {
        this.cmd=cmd;
    }

    public void setAppDeploymentId(String appDeploymentId) {
        this.appDeploymentId=appDeploymentId;
    }

    public void setApplicationDeployment(ApplicationDeployment applicationDeployment) {
        this.applicationDeployment=applicationDeployment;
    }
}
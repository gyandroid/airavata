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
package org.apache.airavata.gfac.gsissh.handler;

import org.apache.airavata.common.exception.ApplicationSettingsException;
import org.apache.airavata.gfac.GFacException;
import org.apache.airavata.gfac.core.context.JobExecutionContext;
import org.apache.airavata.gfac.core.context.MessageContext;
import org.apache.airavata.gfac.core.handler.AbstractRecoverableHandler;
import org.apache.airavata.gfac.core.handler.GFacHandlerException;
import org.apache.airavata.gfac.core.utils.GFacUtils;
import org.apache.airavata.gfac.gsissh.security.GSISecurityContext;
import org.apache.airavata.gfac.gsissh.util.GFACGSISSHUtils;
import org.apache.airavata.gsi.ssh.api.Cluster;
import org.apache.airavata.model.appcatalog.appinterface.DataType;
import org.apache.airavata.model.appcatalog.appinterface.InputDataObjectType;
import org.apache.airavata.model.workspace.experiment.CorrectiveAction;
import org.apache.airavata.model.workspace.experiment.DataTransferDetails;
import org.apache.airavata.model.workspace.experiment.ErrorCategory;
import org.apache.airavata.model.workspace.experiment.TransferState;
import org.apache.airavata.model.workspace.experiment.TransferStatus;
import org.apache.airavata.registry.cpi.ChildDataType;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.Properties;
import java.util.Set;

/**
 * Recoverability for this handler assumes the same input values will come in the second
 * run, and assume nobody is changing registry during the original submission and re-submission
 */
public class GSISSHInputHandler extends AbstractRecoverableHandler {
    private static final Logger log = LoggerFactory.getLogger(GSISSHInputHandler.class);


    public void invoke(JobExecutionContext jobExecutionContext) throws GFacHandlerException {
        super.invoke(jobExecutionContext);
        int index = 0;
        int oldIndex = 0;
        List<String> oldFiles = new ArrayList<String>();
        MessageContext inputNew = new MessageContext();
        DataTransferDetails detail = new DataTransferDetails();
        TransferStatus status = new TransferStatus();
        StringBuffer data = new StringBuffer("|");
        Cluster cluster = null;

        try {
            String hostAddress = jobExecutionContext.getHostName();
            if (jobExecutionContext.getSecurityContext(hostAddress) == null) {
                GFACGSISSHUtils.addSecurityContext(jobExecutionContext);
            }

            cluster = ((GSISecurityContext) jobExecutionContext.getSecurityContext(hostAddress)).getPbsCluster();
            if (cluster == null) {
                throw new GFacException("Security context is not set properly");
            } else {
                log.info("Successfully retrieved the Security Context");
            }

            String pluginData = GFacUtils.getPluginData(jobExecutionContext, this.getClass().getName());
            if (pluginData != null) {
                try {
                    oldIndex = Integer.parseInt(pluginData.split("\\|")[0].trim());
                    oldFiles = Arrays.asList(pluginData.split("\\|")[1].split(","));
                    if (oldIndex == oldFiles.size()) {
                        log.info("Old data looks good !!!!");
                    } else {
                        oldIndex = 0;
                        oldFiles.clear();
                    }
                } catch (NumberFormatException e) {
                    log.error("Previously stored data " + pluginData + " is wrong so we continue the operations");
                }
            }
            if (jobExecutionContext.getSecurityContext(hostAddress) == null) {
                try {
                    GFACGSISSHUtils.addSecurityContext(jobExecutionContext);
                } catch (ApplicationSettingsException e) {
                    log.error(e.getMessage());
                    try {
                        GFacUtils.saveErrorDetails(jobExecutionContext, e.getLocalizedMessage(), CorrectiveAction.CONTACT_SUPPORT, ErrorCategory.AIRAVATA_INTERNAL_ERROR);
                    } catch (GFacException e1) {
                        log.error(e1.getLocalizedMessage());
                    }
                    throw new GFacHandlerException("Error while creating SSHSecurityContext", e, e.getLocalizedMessage());
                }
            }
            log.info("Invoking SCPInputHandler");

            MessageContext input = jobExecutionContext.getInMessageContext();
            Set<String> parameters = input.getParameters().keySet();
            for (String paramName : parameters) {
                InputDataObjectType inputParamType = (InputDataObjectType) input.getParameters().get(paramName);
                String paramValue = inputParamType.getValue();
                //TODO: Review this with type
                if (inputParamType.getType() == DataType.URI) {
                    if (index < oldIndex) {
                        log.info("Input File: " + paramValue + " is already transfered, so we skip this operation !!!");
                        inputParamType.setValue(oldFiles.get(index));
                        data.append(oldFiles.get(index++)).append(","); // we get already transfered file and increment the index
                    } else {
                        String stageInputFile = stageInputFiles(cluster, jobExecutionContext, paramValue);
                        inputParamType.setValue(stageInputFile);
                        StringBuffer temp = new StringBuffer(data.append(stageInputFile).append(",").toString());
                        status.setTransferState(TransferState.UPLOAD);
                        detail.setTransferStatus(status);
                        detail.setTransferDescription("Input Data Staged: " + stageInputFile);
                        registry.add(ChildDataType.DATA_TRANSFER_DETAIL, detail, jobExecutionContext.getTaskData().getTaskID());

                        GFacUtils.savePluginData(jobExecutionContext, temp.insert(0, ++index), this.getClass().getName());
                    }
                } // FIXME: what is the thrift model DataType equivalent for URIArray type?
//                else if ("URIArray".equals(inputParamType.getType().getType().toString())) {
//                    List<String> split = Arrays.asList(StringUtil.getElementsFromString(paramValue));
//                    List<String> newFiles = new ArrayList<String>();
//                    for (String paramValueEach : split) {
//                        if (index < oldIndex) {
//                            log.info("Input File: " + paramValue + " is already transfered, so we skip this operation !!!");
//                            newFiles.add(oldFiles.get(index));
//                            data.append(oldFiles.get(index++)).append(",");
//                        } else {
//                            String stageInputFiles = stageInputFiles(cluster, jobExecutionContext, paramValueEach);
//                            status.setTransferState(TransferState.UPLOAD);
//                            detail.setTransferStatus(status);
//                            detail.setTransferDescription("Input Data Staged: " + stageInputFiles);
//                            registry.add(ChildDataType.DATA_TRANSFER_DETAIL, detail, jobExecutionContext.getTaskData().getTaskID());
//                            StringBuffer temp = new StringBuffer(data.append(stageInputFiles).append(",").toString());
//                            GFacUtils.savePluginData(jobExecutionContext, temp.insert(0, ++index), this.getClass().getName());
//                            newFiles.add(stageInputFiles);
//                        }
//
//                    }
//                    ((URIArrayType) inputParamType.getType()).setValueArray(newFiles.toArray(new String[newFiles.size()]));
//                }
                inputNew.getParameters().put(paramName, inputParamType);
            }
        } catch (Exception e) {
            log.error(e.getMessage());
            status.setTransferState(TransferState.FAILED);
            detail.setTransferDescription(e.getLocalizedMessage());
            detail.setTransferStatus(status);
            try {
                GFacUtils.saveErrorDetails(jobExecutionContext, e.getLocalizedMessage(), CorrectiveAction.CONTACT_SUPPORT, ErrorCategory.FILE_SYSTEM_FAILURE);
                registry.add(ChildDataType.DATA_TRANSFER_DETAIL, detail, jobExecutionContext.getTaskData().getTaskID());
            } catch (Exception e1) {
                throw new GFacHandlerException("Error persisting status", e1, e1.getLocalizedMessage());
            }
            throw new GFacHandlerException("Error while input File Staging", e, e.getLocalizedMessage());
        }
        jobExecutionContext.setInMessageContext(inputNew);
    }

    private static String stageInputFiles(Cluster cluster, JobExecutionContext jobExecutionContext, String paramValue) throws IOException, GFacException {
        int i = paramValue.lastIndexOf(File.separator);
        String substring = paramValue.substring(i + 1);
        try {
            String targetFile = jobExecutionContext.getInputDir() + File.separator + substring;
            if (paramValue.startsWith("file")) {
                paramValue = paramValue.substring(paramValue.indexOf(":") + 1, paramValue.length());
            }
            boolean success = false;
            int j = 1;
            while(!success){
            try {
				cluster.scpTo(targetFile, paramValue);
				success = true;
			} catch (Exception e) {
				log.info(e.getLocalizedMessage());
				Thread.sleep(2000);
				 if(j==3) {
					throw new GFacHandlerException("Error while input File Staging", e, e.getLocalizedMessage());
				 }
            }
            j++;
            }
            return targetFile;
        } catch (Exception e) {
            throw new GFacHandlerException("Error while input File Staging", e, e.getLocalizedMessage());
        }
    }

    public void initProperties(Properties properties) throws GFacHandlerException {

    }

    public void recover(JobExecutionContext jobExecutionContext) throws GFacHandlerException {
        this.invoke(jobExecutionContext);
    }
}

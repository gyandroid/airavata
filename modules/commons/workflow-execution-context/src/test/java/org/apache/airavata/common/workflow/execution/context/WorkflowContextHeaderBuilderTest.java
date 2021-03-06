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
package org.apache.airavata.common.workflow.execution.context;

import org.apache.airavata.common.utils.XMLUtil;
import org.junit.Test;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.io.File;

public class WorkflowContextHeaderBuilderTest {
    private static final Logger log = LoggerFactory.getLogger(WorkflowContextHeaderBuilderTest.class);
    @Test
    public void testExecute() {
        WorkflowContextHeaderBuilder builder = new WorkflowContextHeaderBuilder("brokerurl", "gfacurl", "registryurl",
                "experimentid", "workflowid", "msgBox");

        try {
            File testFile = new File(this.getClass().getClassLoader().getResource("result.xml").getPath());
            org.junit.Assert.assertTrue(XMLUtil.isEqual(XMLUtil.loadXML(testFile),
                    XMLUtil.xmlElement3ToXmlElement5(builder.getXml())));
        } catch (Exception e) {
            log.error(e.getMessage(), e);
        }
    }

}

package org.apache.airavata.xbaya.registrybrowser.model;

import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.apache.airavata.registry.api.Registry;
import org.apache.airavata.registry.api.workflow.WorkflowIOData;

public class XBayaWorkflowExperiments {
	private Registry registry;
	
	public XBayaWorkflowExperiments(Registry registry) {
		setRegistry(registry);
	}
	
	public List<XBayaWorkflowExperiment> getAllExperiments(){
		Map<String, XBayaWorkflowExperiment> experiments=new HashMap<String,XBayaWorkflowExperiment>();
    	List<WorkflowIOData> workflowInput = getRegistry().searchWorkflowInput(null, null, null);
    	List<WorkflowIOData> workflowOutput = getRegistry().searchWorkflowOutput(null, null, null);
    	createChildren(experiments, workflowInput);
    	createChildren(experiments, workflowOutput);
    	return Arrays.asList(experiments.values().toArray(new XBayaWorkflowExperiment[]{}));
	}
	private void createChildren(
			Map<String, XBayaWorkflowExperiment> experiments,
			List<WorkflowIOData> workflowIO) {
		for (WorkflowIOData workflowIOData : workflowIO) {
			if (!experiments.containsKey(workflowIOData.getExperimentId())){
				experiments.put(workflowIOData.getExperimentId(),new XBayaWorkflowExperiment(workflowIOData.getExperimentId(), null));
			}
			XBayaWorkflowExperiment xBayaWorkflowExperiment = experiments.get(workflowIOData.getExperimentId());
			XBayaWorkflow xbayaWorkflow=null;
			for(XBayaWorkflow workflow:xBayaWorkflowExperiment.getWorkflows()){
				if (workflow.getWorkflowId().equals(workflowIOData.getWorkflowId())){
					xbayaWorkflow=workflow;
					break;
				}
			}
			if (xbayaWorkflow==null){
				xbayaWorkflow=new XBayaWorkflow(workflowIOData.getWorkflowId(),workflowIOData.getWorkflowName(),null);
				xBayaWorkflowExperiment.add(xbayaWorkflow);
			}
			
			XBayaWorkflowService workflowService=null;
			for(XBayaWorkflowService service:xbayaWorkflow.getWorkflowServices()){
				if (service.getServiceNodeId().equals(workflowIOData.getNodeId())){
					workflowService=service;
					break;
				}
			}
			
			if (workflowService==null){
				workflowService=new XBayaWorkflowService(workflowIOData.getNodeId(),null,null);
				xbayaWorkflow.add(workflowService);
			}
			
			//TODO setup parameters
		}
	}
	public Registry getRegistry() {
		return registry;
	}
	public void setRegistry(Registry registry) {
		this.registry = registry;
	}

}

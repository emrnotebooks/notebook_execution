# Editor
emr_editor_id=e-XXXXXXXXXXXXXXXXXXXXX
emr_cluster_id=j-XXXXXXXXXX

# Generate a report for day before yesterday
day_before_yesterday=`date -v-2d +'%m-%d-%Y'`

# Start an execution
execution_id=`aws emr --region us-west-2 start-notebook-execution \
--editor-id $emr_editor_id \
--notebook-params '{"DATE":"'"$day_before_yesterday"'", "TOP_K": 6, "US_STATES": ["Wisconsin", "Texas", "Nevada"]}' \
--relative-path demo_pyspark.ipynb \
--notebook-execution-name demo \
--execution-engine '{"Id" : "'"$emr_cluster_id"'"}' \
--service-role EMR_Notebooks_DefaultRole | jq -r .'NotebookExecutionId'`

echo "Started an execution for the date $day_before_yesterday. Execution id: $execution_id"

# Poll for execution to finish
while
    execution_status=`aws emr --region us-west-2 describe-notebook-execution --notebook-execution-id $execution_id | jq -r .'NotebookExecution.Status'`
    echo "Execution Status: $execution_status"
    
    if [ $execution_status == "FINISHED" ] || [ $execution_status == "FAILED" ]; then
    	# Copy the output file to local directory
		output_file=`aws emr --region us-west-2 describe-notebook-execution --notebook-execution-id $execution_id | jq -r .'NotebookExecution.OutputNotebookURI'`
		mkdir -p daily_reports
		aws s3 cp "$output_file" daily_reports/
       break
    fi
    sleep 15s
do true; done




#!/usr/bin/env bash

# Verify imported varables
echo -e "PROJECT_ID is ${PROJECT_ID}"
echo -e "MODULE PATH is ${MODULE_PATH}"

gcloud storage cp --recursive ${MODULE_PATH}/lab_materials/* gs://${PROJECT_ID}

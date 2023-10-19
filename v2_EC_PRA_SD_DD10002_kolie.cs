/* Created: Jen Walters
            Date: 31Oct2022
            Custom Function: EC_PRA_SD_DD10002
            Edit Checks: EC_PRA_SD_DD10002, EC_PRA_SD_DD10002_CROSS
            Description: DDYN.DDYN = Y and all AE records have AE.AESDTH = N or empty


always check for typos in function names
"bool" at top only in def block, not script block
"==" in script; "=" in def block for var
                */
ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
DataPoint dpAction = afp.ActionDataPoint;
Subject subject = dpAction.Record.Subject;

string strQueryText = "Were any death detail assessments collected? is Yes; however, Did the adverse event result in death? is No on the Adverse Event form. Please amend.";
int markingGroupID = 1;
bool responseRequired = false;
bool manualCloseRequired = false;
bool fireQuery = false;


DataPoint dpDDYN = dpAction;
DataPoints dpsAE = CustomFunction.FetchAllDataPointsForOIDPath("AESDTH", "AE", null, subject);

if (dpDDYN != null && dpDDYN.Active && dpDDYN.Data == "Y")
{
    fireQuery = true;
    if (dpsAE.Count > 0)
    {
        for (int i = 0; i < dpsAE.Count; i++)
        {
            if (dpsAE[i] != null && dpsAE[i].Active && dpsAE[i].Data == "Y")
                fireQuery = false;
        }
    }
}


CustomFunction.PerformQueryAction(strQueryText, markingGroupID, responseRequired, manualCloseRequired, dpDDYN, fireQuery);


return null;
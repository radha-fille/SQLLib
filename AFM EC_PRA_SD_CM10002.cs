//AFM EC_PRA_SD_CM10002

-
            /* Created: Jen Walters
             Date: 27Oct2022
             Custom Function: EC_PRA_SD_CM10002
             Edit Checks: EC_PRA_SD_CM10002, EC_PRA_SD_CM10002_CROSS
             Description: CMYN.CMYN = Y and a CM form has been submitted and there are no active records where CM.CMTRT = present
                 */
            ActionFunctionParams afp = (ActionFunctionParams)ThisObject;
DataPoint dpAction = afp.ActionDataPoint;
Subject subject = dpAction.Record.Subject;
Instance ins = dpAction.Record.DataPage.Instance;
DataPage dpg = ins.DataPages.FindByFormOID("CM");

string strQueryText = "Were any medications taken? is Yes, however Prior/Concomitant Medication information is missing on the Prior/Concomitant Medication form. Please reconcile.";
int markingGroupID = 1;
bool responseRequired = false;
bool manualCloseRequired = false;
bool fireQuery = false;

//be careful: alphas need caps : DataPages not datapages
// IsNew in code below checks to make sure AE page is triggered and exists so that query doesn't fire same time as the DYN action to trigger form
//before user can enter data or leave blank


DataPoint dpCMYN = dpAction;
DataPoints dpCM = CustomFunction.FetchAllDataPointsForOIDPath("CMTRT", "CM", null, subject);

if (dpCMYN != null && dpCMYN.Active && dpCMYN.Data == "Y")
{
    if (dpg != null && dpg.Active && !dpg.IsNew)
    {
        fireQuery = true;
        if (dpCM.Count > 0)
        {
            for (int i = 0; i < dpCM.Count && fireQuery; i++)
            {
                if (dpCM[i] != null && dpCM[i].Active && dpCM[i].Data != string.Empty)
                    fireQuery = false;
            }
        }
    }
    if (dpg != null)


    {
        if (!dpg.Active && !dpg.IsNew && dpg.IsUserDeactivated)
            fireQuery = true;
    }
}

CustomFunction.PerformQueryAction(strQueryText, markingGroupID, responseRequired, manualCloseRequired, dpCMYN, fireQuery);


return null;
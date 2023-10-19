/***********************************************************************
        Check Name : CF_MERGE_MATRIX_RETREAT
        Programmer Name : adel.mackay@iconplc.com
        Date Created : 9-May-2023
        Desc : If C1D29.CONTVIS.CONTVIS = PRERETREAT, then Merge Matrix PRE_RETREAT.  If CONT_PRE.CONTYN_PRE = Y after the first PRE_V2 folder is added, 
               add another instance of the PRE_V2 folder.Append the VISIT.VISITDAT to the end of the PRE_V2 folder name.
               Adds initial Pre-Retreatment  folder and additiona Pre-Retreatment folders as needed.
        Modified By :
        Modified Date :
        Modification History :
        ********************************************************************/
        ActionFunctionParams afp = (ActionFunctionParams) ThisObject;
        DataPoint dpAction = afp.ActionDataPoint;
        Subject subject = dpAction.Record.Subject;

        Matrix matrix_PRETREAT = Matrix.FetchByOID("PRE_RETREAT", subject.CRFVersion.ID);
        int subjectMatrixID = dpAction.Record.SubjectMatrixID;
        string[] strForms =
        {
            "VISIT", "PE2", "VS", "VSLOG", "QS", "LB", "NEURO_MINI", "CONT_PRE"
        }
        ;
        ArrayList arrForms = new ArrayList(strForms);

        bool doMerge = false;
        bool blFolderAdd = false;
        bool blnAdd = false;    
        if (dpAction.Field.OID == "CONTVIS")
        {
            if (dpAction.Data.ToString() != string.Empty && dpAction.Data.ToString() == "PRERETREAT")
            {
                doMerge = true;
            }
            if (matrix_PRETREAT != null && doMerge == true)
                subject.MergeMatrix(matrix_PRETREAT);
            
            if (matrix_PRETREAT != null && doMerge == false)
                subject.UnMergeMatrix(matrix_PRETREAT);
        }
        else if (dpAction.Field.OID == "CONTYN_PRE")
        {      
            Instance insC = dpAction.Record.DataPage.Instance;
            DataPage dpgCONT_PRE = insC.DataPages.FindByFormOID("CONT_PRE");
            if (dpgCONT_PRE != null)
            {
                DataPoint dpCONTYN_PRE = dpgCONT_PRE.MasterRecord.DataPoints.FindByFieldOID("CONTYN_PRE");
                if (dpCONTYN_PRE != null && dpCONTYN_PRE.Active && dpCONTYN_PRE.Data != string.Empty && dpCONTYN_PRE.Data == "Y")
                {
                    blnAdd = true;
                }
                else
                {
                    blnAdd = false;
                }              
                    
                int intFolderNum = dpAction.Record.DataPage.Instance.InstanceRepeatNumber;
                Instance insP = dpAction.Record.Subject.Instances.FindByFolderOID("PRE_C2");
                if (insP != null)
                {
                    Instances instsPRE = insP.Instances;
                    Instance instNextInstance = null;
                    blFolderAdd = true;
                    for (int i = 0; i < instsPRE.Count; i++)
                    {
                        Folder fldPRE = instsPRE[i].Folder;
                        string strPRE = fldPRE.OID;
                        if (intFolderNum == instsPRE[i].InstanceRepeatNumber - 1)
                        {
                            blFolderAdd = false;
                            instNextInstance = instsPRE[i];
                        }
                        if (instsPRE[i].InstanceRepeatNumber > intFolderNum && !blnAdd)
                        {
                            AddForm(instsPRE[i], arrForms, blnAdd);
                            if (instsPRE[i] != null && !instsPRE[i].IsBitSet(Status.IsTouched))
                            {
                                instsPRE[i].Active = false;
                            }
                        }
                    }
                    AddInstance(insP, instNextInstance, subject, "PRE_V2", subjectMatrixID, blnAdd, arrForms, blFolderAdd);
                }
            }
        }
        else if (dpAction.Field.OID == "VISITDAT")
        {      
            if (dpAction != null)
            {
                Instance ins = dpAction.Record.DataPage.Instance;
                if (dpAction.Active && dpAction.Data.ToString() != string.Empty && dpAction.StandardValue() is DateTime)
                    ins.SetInstanceName("_" + dpAction.Data.ToString());
                else
                    ins.SetInstanceName("");
            }
        }

        return null;
        }

        void AddInstance(Instance insParent, Instance insCurrent, Subject subj, string folderOid, int SubjMatrixID, bool isAdd, ArrayList arrforms, bool blnFolderAdd) 
        {
            if (isAdd && blnFolderAdd)
            {
                Folder newfolder = Folder.FetchByOID(folderOid, subj.CRFVersion.ID);
                if (newfolder != null)
                {
                    Instance newIns = new Instance(insParent, newfolder, SubjMatrixID);
                    subj.Instances.Add(newIns);
                    AddForm(newIns, arrforms, isAdd);
                }
            }
            else if (isAdd && !blnFolderAdd)
            {
                insCurrent.Active = true;
                AddForm(insCurrent, arrforms, isAdd);
           }
        }

        void AddForm(Instance inst, ArrayList arrForms, bool doAdd) 
        {
            if (inst != null && inst.Active)
            {
                for (int i = 0; i < arrForms.Count; i++)
                {
                    DataPage newPage = inst.DataPages.FindByFormOID(arrForms[i].ToString());
                    if (doAdd) 
                    {
                        if (newPage == null) 
                        {
                            Form newForm = Form.FetchByOID(arrForms[i].ToString(), inst.Subject.CRFVersion.ID);
                            newPage = new DataPage(inst, newForm, inst.SubjectMatrixID);
                            inst.DataPages.Add(newPage);
                        }
                        else
                        {
                            newPage.Active = true;
                        }
                    }
                    else
                    {
                        if (newPage != null && newPage.Active && !newPage.IsBitSet(Status.IsTouched))
                            newPage.Active = false;
                    }
                }
            }
        }

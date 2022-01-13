using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using MySql.Data.MySqlClient;
using System.Data;
using OfficeOpenXml;
using OfficeOpenXml.Table;
using System.IO;

namespace EMRPortal
{
    public partial class home : System.Web.UI.Page
    {
        List<string> facilities;


        protected void Page_Load(object sender, EventArgs e)
        {
            string sCategory = Request.QueryString["cat"];
            IEnumerable<string> files = Directory.EnumerateFiles(Server.MapPath("~/queries/common"));

            if (sCategory == "general")
            {
                lblTitle.Text = "General Queries";
                lblBreadcrumb.Text = "General Queries";
                files = Directory.EnumerateFiles(Server.MapPath("~/queries/common"));
            }
            else if (sCategory == "hts")
            {
                lblTitle.Text = "HTS Queries";
                lblBreadcrumb.Text = "HTS Queries";
                files = Directory.EnumerateFiles(Server.MapPath("~/queries/hts"));
            }
            else if (sCategory == "hiv")
            {
                lblTitle.Text = "HIV Queries";
                lblBreadcrumb.Text = "HIV Queries";
                files = Directory.EnumerateFiles(Server.MapPath("~/queries/hiv"));
            }
            else if (sCategory == "pmtct")
            {
                lblTitle.Text = "PMTCT Queries";
                lblBreadcrumb.Text = "PMTCT Queries";
                files = Directory.EnumerateFiles(Server.MapPath("~/queries/pmtct"));
            }
            else if (sCategory == "prep")
            {
                lblTitle.Text = "PrEP Queries";
                lblBreadcrumb.Text = "PrEP Queries";
                files = Directory.EnumerateFiles(Server.MapPath("~/queries/prep"));
            }

            if (!IsPostBack)
            {
                txtStartDate.Text = DateTime.Now.ToShortDateString();
                txtEndDate.Text = DateTime.Now.ToShortDateString();
                divFromDate.Visible = false;
                divToDate.Visible = false;

                string sQuery = @"select SCHEMA_NAME as db_name, replace(SCHEMA_NAME, 'openmrs_','') as facility_name from information_schema.SCHEMATA where SCHEMA_NAME like 'openmrs%'
                                union all
                                select '9999', 'ALL FACILITIES';";

                lstFacilities.DataSource = ExecuteQuery(sQuery);
                lstFacilities.DataTextField = "facility_name";
                lstFacilities.DataValueField = "db_name";
                lstFacilities.DataBind();

                foreach (var fullPath in files)
                {
                    var fileNamewithoutext = Path.GetFileNameWithoutExtension(fullPath);
                    //var fileName = Path.GetFileName(fullPath);
                    ListItem item = new ListItem(fileNamewithoutext, fullPath);
                    ddlQuery.Items.Add(item);
                }

                ddlQuery.Items.Insert(0, "");
            }
        }

        protected void btnLoad_Click(object sender, EventArgs e)
        {
            btnLoad.Enabled = false;
            lbProgress.Text = "Loading data..... Please wait";

            facilities = new List<string>();

            for (int i = 0; i < lstFacilities.Items.Count; i++)
            {
                if (lstFacilities.Items[i].Selected)
                {
                    if (lstFacilities.Items[i].Text.Contains("ALL FACILITIES"))
                    {
                        string sQuery = @"select SCHEMA_NAME as db_name, replace(SCHEMA_NAME, 'openmrs_','') as facility_name from information_schema.SCHEMATA where SCHEMA_NAME like 'openmrs%';";
                        DataTable dt = ExecuteQuery(sQuery);
                        foreach(DataRow dr in dt.Rows)
                        {
                            facilities.Add(dr["db_name"].ToString());
                        }
                    }
                    else
                    {
                        facilities.Add("openmrs_" + lstFacilities.Items[i].Text);
                    }
                }
            }

            //set the query
            string filepath = ddlQuery.SelectedItem.Value.ToString();
            string data = File.ReadAllText(filepath);

            string startdate = Convert.ToDateTime(txtStartDate.Text).ToString("yyyy-MM-dd");
            string enddate = Convert.ToDateTime(txtEndDate.Text).ToString("yyyy-MM-dd");

            Session["query"] = data.Replace("openmrs.", "")
                .Replace("kenyaemr_etl.", "")
                .Replace("kenyaemr_datatools.", "tools_")
                .Replace("@fromdate", "'" + startdate + "'")
                .Replace("@todate", "'" + enddate + "'");

            BackgroundWorker worker = new BackgroundWorker();
            worker.DoWork += new BackgroundWorker.DoWorkEventHandler(worker_DoWork);
            worker.RunWorker();

            // It needs Session Mode is "InProc"
            // to keep the Background Worker working.
            Session["worker"] = worker;

            // Enable the timer to update the status of the operation.
            Timer1.Enabled = true;
        }

        private void worker_DoWork(ref int progress, ref object result, params object[] arguments)
        {
            Session["error"] = "false";
            Session["process"] = "starting loading the process";
            Session["db_errors"] = "";

            try
            {
                DataTable dtAll = new DataTable();
                DataTable dt_load;

                for (int i = 0; i < facilities.Count; i++)
                {
                    Session["facility"] = facilities[i];
                    Session["process"] = "loading data from " + facilities[i];

                    try
                    {
                        dt_load = ExecuteQuery("use " + facilities[i] + "; " + Session["query"].ToString());
                    }
                    catch(Exception ex)
                    {
                        dt_load = null;
                        Session["db_errors"] = Session["db_errors"] + "<br>" + "Error on " + facilities[i] + ": " + ex.Message;
                    }

                    if (dt_load != null)
                    {
                        if (dt_load.Rows.Count == 0)
                        {
                            dtAll = dt_load;
                        }
                        else
                        {
                            dtAll.Merge(dt_load);
                        }
                    }

                    int prog = (int)((double)(i + 1) / (double)(facilities.Count) * 80.0);
                    progress = prog;
                }

                Session["process"] = "exporting data to excel";

                if (dtAll.Rows.Count > 0)
                {
                    string downloadlink = ExportToExcel(dtAll);

                    //The operation is completed.
                    result = "Data generated successfully. <a href='" + downloadlink + "'>Download it here</a><br>" + Session["db_errors"];
                }
                else
                {
                    Session["error"] = "true";
                    result = "An empty dataset was generated. There is no data to download<br>" + Session["db_errors"];
                }

                progress = 100;
            }
            catch (Exception ex)
            {
                Session["error"] = "true";
                result = "The following error occured when " + Session["process"].ToString() + ": " + ex.Message;
            }
        }

        public string ExportToExcel(DataTable dt)
        {
            var rowCount = dt.Rows.Count;

            string filename = "Data_export_" + DateTime.Now.ToString("yyyy_MM_dd_HH_mm") + ".xlsx";
            string finalFileNameWithPath = Path.Combine(Server.MapPath(" "), "reports", filename);
            string dlink = ResolveUrl("~/reports/") + filename;

            //Delete existing file with same file name.
            if (File.Exists(finalFileNameWithPath))
                File.Delete(finalFileNameWithPath);

            var newFile = new FileInfo(finalFileNameWithPath);
            newFile.Directory.Create();
            using (var package = new ExcelPackage(newFile))
            {
                ExcelWorksheet worksheet = package.Workbook.Worksheets.Add("Data");

                worksheet.Cells["A1"].LoadFromDataTable(dt, true, TableStyles.Medium2);
                var dateColumns = from DataColumn d in dt.Columns
                                  where d.DataType == typeof(DateTime) || d.ColumnName.Contains("Date")
                                  select d.Ordinal + 1;

                foreach (var dc in dateColumns)
                {
                    worksheet.Cells[2, dc, rowCount + 1, dc].Style.Numberformat.Format = "dd-MMM-yyyy";
                }
                worksheet.Cells[worksheet.Dimension.Address].AutoFitColumns();

                package.Save();
            }

            return dlink;
        }

        private DataTable ExecuteQuery(string sQuery)
        {
            try
            {
                MySqlConnection conn = new MySqlConnection(UtilityFunctions.ConnectionString);
                MySqlCommand command = new MySqlCommand(sQuery, conn);
                command.CommandTimeout = 0;
                MySqlDataAdapter adapter = new MySqlDataAdapter(command);
                DataSet dataset = new DataSet();
                DataTable dt;

                adapter.Fill(dataset);
                dt = dataset.Tables[0];

                return dt;
            }
            catch (Exception ex)
            {
                throw ex;
            }
        }

        protected void Timer1_Tick(object sender, EventArgs e)
        {
            // Show the progress of current operation.
            BackgroundWorker worker = (BackgroundWorker)Session["worker"];
            if (worker != null)
            {
                // Display the progress of the operation.
                lbProgress.Text = "<h2><font color='green'>Loading data..... " + worker.Progress.ToString() + "%</font></h2>";

                //btnRefresh.Enabled = !worker.IsRunning;
                Timer1.Enabled = worker.IsRunning;

                // Display the result when the operation completed.
                if (worker.Progress >= 100)
                {
                    lbProgress.Text = "<h3><font color='green'>" + (string)worker.Result + "</font></h3>";
                }

                if (!worker.IsRunning)
                {
                    if (Session["error"].ToString() == "true")
                    {
                        lbProgress.Text = "<h3><font color='red'>" + (string)worker.Result + "</font></h3>";
                    }
                    else
                    {
                        lbProgress.Text = "<h3><font color='green'>" + (string)worker.Result + "</font></h3>";
                    }

                    btnLoad.Enabled = true;
                }
            }
        }

        protected void ddlQuery_SelectedIndexChanged(object sender, EventArgs e)
        {
            try
            {
                string filepath = ddlQuery.SelectedItem.Value.ToString();
                string data = File.ReadAllText(filepath);
                if (data.Contains("@fromdate"))
                {
                    divFromDate.Visible = true;
                }
                else
                {
                    divFromDate.Visible = false;
                }

                if (data.Contains("@todate"))
                {
                    divToDate.Visible = true;
                }
                else
                {
                    divToDate.Visible = false;
                }
            }
            catch { }
        }
    }
}
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;
using MySql.Data.MySqlClient;

namespace EMRPortal
{
    public partial class _default : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            
        }

        private DataTable ExecuteQuery(string sQuery)
        {
            try
            {
                MySqlConnection conn = new MySqlConnection(UtilityFunctions.ConnectionString);
                MySqlCommand command = new MySqlCommand(sQuery, conn);
                MySqlDataAdapter adapter = new MySqlDataAdapter(command);
                DataSet dataset = new DataSet();
                DataTable dt;

                adapter.Fill(dataset);
                dt = dataset.Tables[0];

                return dt;
            }
            catch (Exception ex)
            {
                return null;
            }
        }

        protected void btnLogin_Click(object sender, EventArgs e)
        {
            DataTable dt = ExecuteQuery("select * from emrportal.systemuser where username='" + txtUsername.Text + "' and pwd=password('" + txtPassword.Text + "')");

            if (dt.Rows.Count > 0)
            {
                Session["user_username"] = dt.Rows[0]["username"];
                Session["user_pwd"] = dt.Rows[0]["pwd"];

                Response.Redirect("home.aspx");
            }
            else
            {
                ScriptManager.RegisterClientScriptBlock(this, GetType(), "user_login_failed", "alert('User login failed, please try again');", true);
            }
        }
    }
}
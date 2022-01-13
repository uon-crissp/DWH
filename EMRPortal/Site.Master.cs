using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EMRPortal
{
    public partial class Site1 : System.Web.UI.MasterPage
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            if (Session["user_username"] == null)
            {
                Response.Redirect("Default.aspx");
            }
            else
            {
                string[] sname = Session["user_username"].ToString().Split('@');
                lblUsername.Text = sname[0];
            }
        }
    }
}
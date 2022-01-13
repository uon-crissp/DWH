using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;

namespace EMRPortal
{
    public partial class logout : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {
            Session["user_id"] = null;
            Session["user_pwd"] = null;
            Session["user_username"] = null;
            Session["user_nameofuser"] = null;

            Response.Redirect("default.aspx");
        }
    }
}
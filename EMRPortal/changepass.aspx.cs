using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.UI;
using System.Web.UI.WebControls;
using System.Data;

namespace EMRPortal
{
    public partial class changepass : System.Web.UI.Page
    {
        protected void Page_Load(object sender, EventArgs e)
        {

        }

        protected void btnChange_Click(object sender, EventArgs e)
        {
            try
            {
                if (txtConfirmPass.Text != txtNewPass.Text)
                {
                    UtilityFunctions.ShowMessage(this, "Error", "The new password and re-entered password do not match", UtilityFunctions.MessageType.ERROR);
                    return;
                }

                DataTable dt =  UtilityFunctions.ExecuteQuery("select * from emrportal.systemuser where username='" + Session["user_username"].ToString() + "' and pwd=password('" + txtCurrentPass.Text + "')");
                if (dt.Rows.Count == 0)
                {
                    UtilityFunctions.ShowMessage(this, "Error on saving", "The current password entered is wrong. Please renter", UtilityFunctions.MessageType.ERROR);
                }
                else
                {
                    UtilityFunctions.ExecuteQuery("update emrportal.systemuser set pwd=password('"+txtNewPass.Text+"') where username='" + Session["user_username"].ToString() + "'");
                    UtilityFunctions.ShowMessage(this, "Success!", "Details saved successfully in database", UtilityFunctions.MessageType.SUCCESS);
                    UtilityFunctions.ClearInputs(Page.Controls);
                }
            }
            catch (Exception ex)
            {
                UtilityFunctions.ShowMessage(this, "Error on saving", ex.Message, UtilityFunctions.MessageType.ERROR);
            }
        }
    }
}
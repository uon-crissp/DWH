<%@ Page Title="" Language="C#" MasterPageFile="~/Site.Master" AutoEventWireup="true"
    CodeBehind="changepass.aspx.cs" Inherits="EMRPortal.changepass" %>

<asp:Content ID="Content1" ContentPlaceHolderID="head" runat="server">
</asp:Content>
<asp:Content ID="Content2" ContentPlaceHolderID="ContentPlaceHolder1" runat="server">
    <div class="row">
        <ol class="breadcrumb">
            <li><a href="#"><em class="fa fa-home"></em></a></li>
            <li class="active">
                <asp:Label ID="lblBreadcrumb" runat="server" Text="Change Password"></asp:Label></li>
        </ol>
    </div>
    <!--/.row-->
    <div class="row">
        <div class="col-lg-12">
            <h1 class="page-header">
                <asp:Label ID="lblTitle" runat="server" Text="Change Password"></asp:Label></h1>
        </div>
    </div>
    <!--/.row-->
    <div class="row">
        <div class="col-md-6" runat="server" id="divFromDate">
            <div class="form-group">
                <label>
                    Current Password:</label>
                <asp:TextBox ID="txtCurrentPass" runat="server" CssClass="form-control" type="password" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6" runat="server" id="divToDate">
            <div class="form-group">
                <label>
                    New Password:</label>
                <asp:TextBox ID="txtNewPass" runat="server" CssClass="form-control" type="password" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6">
            <div class="form-group">
                <label>
                    Confirm Password:
                </label>
                <asp:TextBox ID="txtConfirmPass" runat="server" CssClass="form-control" type="password" required />
            </div>
        </div>
    </div>
    <div class="row">
        <div class="col-md-6">
            <div class="form-group">
                <asp:Button ID="btnChange" runat="server" Text="Save Changes" value="Save Changes" CssClass="btn btn-success btn-lg btn-block"
                    type="button" OnClick="btnChange_Click" />
            </div>
        </div>
    </div>
</asp:Content>

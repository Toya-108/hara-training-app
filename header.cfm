<cfinclude template="init.cfm">

<cfparam name="pageTitle" default="タイトル未設定">
<cfparam name="showHomeButton" default="false">
<cfparam name="showNewButton" default="false">
<cfparam name="showEditButton" default="false">
<cfparam name="showImportButton" default="false">
<cfparam name="showExportButton" default="false">
<cfparam name="showBackButton" default="false">
<cfparam name="showTrashButton" default="false">
<cfparam name="showCancelButton" default="false">

<cfoutput>
    <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
</cfoutput>


<style>
  .header-left {
    width: 120px;
    display: flex;
    align-items: center;
    gap: 8px;
  }

  .header-title {
    margin: 0;
    font-size: 24px;
    font-weight: bold;
    color: #2E4136;
    text-align: center;
    flex: 1;
  }

  .header-actions {
    width: 180px;
    display: flex;
    justify-content: flex-end;
    align-items: center;
    gap: 8px;
  }

  .header-btn:hover {
    background-color: #EFE5D1;
  }

  .header-btn:active {
    background-color: #E2D6BE;
  }

  .edit-btn,
  .cancel-btn {
    width: 16px !important;
  }
</style>

<cfoutput>

<link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260326_1">

<header class="app-header">
  <div class="header-left">
    <cfif showHomeButton>
      <button id="home-btn" class="header-btn home-btn" type="button" title="ホーム">
        <img src="#Application.asset_url#/image/home-icon.svg" alt="ホームボタン">
      </button>
    </cfif>

    <cfif showBackButton>
      <button id="back-btn" class="header-btn back-btn" type="button" title="戻る">
        <img src="#Application.asset_url#/image/back-icon.svg" alt="戻るボタン">
      </button>
    </cfif>
  </div>

  <h1 class="header-title">#HTMLEditFormat(pageTitle)#</h1>

  <div class="header-actions">
    <cfif showNewButton>
      <button class="header-btn" id="add-button" type="button" title="新規登録">
        <img src="#Application.asset_url#/image/add-icon.svg" alt="新規登録ボタン" class="add-btn">
      </button>
    </cfif>

    <cfif showEditButton>
      <button class="header-btn" id="edit-button" type="button" title="修正">
        <img src="#Application.asset_url#/image/edit-icon.svg" alt="修正ボタン" class="edit-btn">
      </button>
    </cfif>

    <cfif showTrashButton>
      <button class="header-btn" id="trash-button" type="button" title="削除">
        <img src="#Application.asset_url#/image/trash-icon.svg" alt="削除ボタン" class="trash-btn">
      </button>
    </cfif>

    <cfif showCancelButton>
      <button class="header-btn" id="cancel-button" type="button" title="キャンセル">
        <img src="#Application.asset_url#/image/cancel-icon.svg" alt="キャンセルボタン" class="cancel-btn">
      </button>
    </cfif>

    <cfif showImportButton>
      <button class="header-btn" id="import-button" type="button" title="インポート">
        ↓
      </button>
    </cfif>

    <cfif showExportButton>
      <button class="header-btn export-btn" id="export-button" type="button" title="エクスポート">
        <img src="#Application.asset_url#/image/export-icon.svg" alt="エクスポートボタン">
      </button>
    </cfif>
  </div>
</header>
</cfoutput>
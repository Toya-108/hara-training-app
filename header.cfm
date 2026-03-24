<cfinclude template="init.cfm">

<cfparam name="pageTitle" default="タイトル未設定">
<cfparam name="showBackButton" default="false">
<cfparam name="showNewButton" default="false">
<cfparam name="showImportButton" default="false">
<cfparam name="showExportButton" default="false">

<style>
  .header-left {
    width: 120px;
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
    width: 120px;
    display: flex;
    justify-content: flex-end;
    gap: 8px;
  }

  .header-btn:hover {
    background-color: #EFE5D1;
  }

  .header-btn:active {
    background-color: #E2D6BE;
  }
</style>

<cfoutput>
<header class="app-header">
  <link rel="stylesheet" href="#Application.asset_url#/css/style.css?20260319">
  <div class="header-left">
    <cfif showBackButton>
      <button id="back-btn" class="header-btn" type="button" title="戻る">
        <img src="#Application.asset_url#/image/home-icon.svg" alt="戻るボタン">
      </button>
    </cfif>
  </div>

    <h1 class="header-title">#pageTitle#</h1>

  <div class="header-actions">
    <cfif showNewButton>
      <button class="header-btn" type="button" title="新規登録">
        <img src="#Application.asset_url#/image/add-icon.svg" alt="新規登録ボタン">
      </button>
    </cfif>

    <cfif showImportButton>
      <button class="header-btn" type="button" title="インポート">↓</button>
    </cfif>

    <cfif showExportButton>
      <button class="header-btn" type="button" title="エクスポート">
        <img src="#Application.asset_url#/image/export-icon.svg" alt="エクスポートボタン">
      </button>
    </cfif>
  </div>
</header>
</cfoutput>

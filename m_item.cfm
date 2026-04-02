<cfinclude template="init.cfm">

<cfset pageTitle = "商品マスタ一覧">
<cfset showHomeButton = true>

<cfif session.authorityLevel eq 9>
  <cfset showNewButton = true>
  <cfset showExportButton = true>
<cfelse>
  <cfset showNewButton = false>
  <cfset showExportButton = false>
</cfif>

<cfparam name="Form.search_product_code" default="">
<cfparam name="Form.search_jan_code" default="">
<cfparam name="Form.search_product_name" default="">

<cfset formSortField = "">
<cfif StructKeyExists(Form, "sort_field")>
  <cfset formSortField = Trim(Form.sort_field)>
</cfif>

<cfset formSortOrder = "">
<cfif StructKeyExists(Form, "sort_order")>
  <cfset formSortOrder = LCase(Trim(Form.sort_order))>
</cfif>

<cfset formPage = "1">
<cfif StructKeyExists(Form, "page") AND IsNumeric(Form.page) AND Val(Form.page) gt 0>
  <cfset formPage = Form.page>
</cfif>

<html lang="ja">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>商品マスタ一覧</title>
      <cfoutput>
          <link rel="icon" href="#Application.asset_url#/image/hara-logiapp-logo.ico">
          <link rel="stylesheet" href="#Application.asset_url#/css/style.css">
      </cfoutput>

      <style>
        body {
          background-color: #F7F1E3;
          color: #2F2A24;
        }

        .search_area {
          margin-left: 60px;
        }

        .search_item {
          margin-left: 20px;
          margin-right: 20px;
        }

        .search_item label {
          display: block;
          margin-bottom: 6px;
          font-size: 14px;
          font-weight: bold;
          color: #2E4136;
        }

        .search_item input {
          height: 34px;
          padding: 0 14px;
          border: 1px solid #CDBFA8;
          border-radius: 5px;
          font-size: 15px;
          background-color: #FFFFFF;
          color: #2F2A24;
          line-height: 34px;
        }

        .search_item input:focus {
          border-color: #3F5B4B;
          background-color: #FFFCF4;
          box-shadow: 0 0 0 1px rgba(63, 91, 75, 0.15);
          outline: none;
        }

        .search_item input::placeholder {
          color: #8A8175;
        }

        .search_btn_area {
          display: flex;
          align-items: flex-end;
          gap: 10px;
        }

        .icon_btn {
          background: transparent;
          border: none;
          cursor: pointer;
          padding: 0;
          border-radius: 6px;
        }

        .icon_btn:hover {
          background: #EFE5D1;
        }

        .search_btn img {
          width: 40px;
          height: 40px;
          display: block;
        }

        .table_scroll {
          max-height: 65%;
          overflow-y: auto;
          overflow-x: auto;
        }

        .table_div {
          margin: 0 80px 80px;
        }

        .list_table {
          width: 100%;
          border-collapse: collapse;
          background-color: #FFFFFF;
        }

        .list_table th,
        .list_table td {
          border: 1px solid #CDBFA8;
          padding: 8px 10px;
        }

        .list_table th {
          background: #EFE5D1;
          color: #2E4136;
          position: sticky;
          top: 0;
        }

        .list_table td {
          color: #2F2A24;
        }

        .paging_info_area {
          margin: 24px 80px 0;
          display: flex;
          justify-content: space-between;
          align-items: center;
        }

        .page_status {
          font-size: 16px;
          font-weight: bold;
          color: #2E4136;
        }

        .paging_dummy {
          display: flex;
          align-items: center;
          gap: 10px;
        }

        .paging_btn {
          min-width: 80px;
          height: 34px;
          border: 1px solid #CDBFA8;
          border-radius: 6px;
          background: #FFFFFF;
          color: #2E4136;
          cursor: pointer;
          padding: 0 12px;
        }

        .paging_btn:hover:not(:disabled) {
          background: #EFE5D1;
        }

        .paging_btn:disabled {
          opacity: 0.5;
          cursor: not-allowed;
        }

        .page_number_text {
          min-width: 90px;
          text-align: center;
          color: #2E4136;
          font-weight: bold;
        }

        .loading_text {
          text-align: center;
          color: #645B50;
        }

        .error_text {
          text-align: center;
          color: #B84A4A;
        }

        .sort_btn.active img {
          opacity: 1;
        }

        .sort_btn:hover img {
          opacity: 0.8;
        }

        .loading_indicator {
          display: none;
          margin: 16px 80px 0;
          padding: 10px 14px;
          border: 1px solid #CDBFA8;
          border-radius: 8px;
          background-color: #F5EEDC;
          color: #2E4136;
          font-size: 14px;
          font-weight: bold;
        }

        .loading_indicator.is-visible {
          display: block;
        }

        .item_table_body tr {
          cursor: pointer;
        }

        .item_table_body tr:hover {
          background-color: #FFFCF4;
        }
      </style>
    </head>
    <body>
    <cfoutput>

      <cfinclude template="header.cfm">

      <form action="" method="post" id="master_form" class="search_form">
        <input type="hidden" id="return_sort_field" name="sort_field" value="#HTMLEditFormat(formSortField)#">
        <input type="hidden" id="return_sort_order" name="sort_order" value="#HTMLEditFormat(formSortOrder)#">
        <input type="hidden" id="return_page" name="page" value="#HTMLEditFormat(formPage)#">

        <div class="wrap">

          <div class="search_area" style="display:flex;margin-top:30px;">
            <div class="search_item">
              <label for="search_product_code">商品コード</label>
              <input
                type="text"
                id="search_product_code"
                name="search_product_code"
                placeholder="商品コード"
                value="#HTMLEditFormat(Form.search_product_code)#"
              >
            </div>

            <div class="search_item" style="margin-top:3px;">
              <label for="search_jan_code">JAN</label>
              <input
                type="text"
                id="search_jan_code"
                name="search_jan_code"
                placeholder="JANコード"
                value="#HTMLEditFormat(Form.search_jan_code)#"
              >
            </div>

            <div class="search_item">
              <label for="search_product_name">商品名</label>
              <input
                type="text"
                id="search_product_name"
                name="search_product_name"
                placeholder="商品コード / JANコード / 商品名 / 商品名(カナ)"
                value="#HTMLEditFormat(Form.search_product_name)#"
                style="width:350px;"
              >
            </div>

            <div class="search_btn_area" style="display:flex;">
              <button type="button" id="search_btn" class="icon_btn search_btn" title="検索">
                <img src="#Application.asset_url#/image/search-icon.svg" alt="検索">
              </button>
              <button type="button" id="clear_btn" class="icon_btn search_btn clear_btn" title="クリア">
                <img src="#Application.asset_url#/image/clear-icon.svg" alt="クリア">
              </button>
            </div>
          </div>

          <div class="paging_info_area">
            <div id="page_status" class="page_status">1 / 1 ページ</div>

            <div class="paging_dummy">
              <button type="button" id="first_page_btn" class="paging_btn">TOP</button>
              <button type="button" id="prev_page_btn" class="paging_btn">Prev</button>
              <div id="page_number_text" class="page_number_text">1 / 1</div>
              <button type="button" id="next_page_btn" class="paging_btn">Next</button>
              <button type="button" id="last_page_btn" class="paging_btn">END</button>
            </div>
          </div>

          <div id="loading_indicator" class="loading_indicator">
            読み込み中です...
          </div>

          <div style="margin-top:30px;">
            <div class="table_div">
              <div class="table_scroll">
                <table class="list_table item_table">
                  <thead>
                    <tr>
                      <th style="width:120px;">
                        商品コード
                        <span class="sort_btn" data-field="item_code" data-sort="none">
                          <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                      </th>
                      <th style="width:120px;">
                        JAN
                        <span class="sort_btn" data-field="jan_code" data-sort="none">
                          <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                      </th>
                      <th>
                        商品名
                        <span class="sort_btn" data-field="item_name" data-sort="none">
                          <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                      </th>
                      <th style="width:180px;">
                        作成日時
                        <span class="sort_btn" data-field="create_datetime" data-sort="none">
                          <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                      </th>
                      <th style="width:180px;">
                        更新日時
                        <span class="sort_btn" data-field="update_datetime" data-sort="none">
                          <img src="#Application.asset_url#/image/sort_default.svg" alt="ソート">
                        </span>
                      </th>
                    </tr>
                  </thead>

                  <tbody id="item_table_body" class="item_table_body">
                  </tbody>
                </table>
              </div>
            </div>
          </div>

        </div>
      </form>

      <script>
      window.initialItemListState = {
        sortField: "#JSStringFormat(formSortField)#",
        sortOrder: "#JSStringFormat(formSortOrder)#",
        page: "#JSStringFormat(formPage)#"
      };
      </script>
      <script src="#Application.asset_url#/js/m_item.js?20260331_keep_state_1"></script>
    </cfoutput>
    </body>
</html>
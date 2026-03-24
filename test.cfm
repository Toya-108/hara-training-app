<!DOCTYPE html>
<html lang="ja">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>テーブル分割テスト</title>

    <style>
        * {
            box-sizing: border-box;
        }

        body {
            margin: 0;
            padding: 24px;
            background-color: #F7F1E3;
            color: #2F2A24;
            font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Hiragino Sans", "Yu Gothic", sans-serif;
        }

        .page-title {
            margin: 0 0 20px 0;
            font-size: 24px;
            color: #2E4136;
        }

        .table-area {
            width: 100%;
            max-width: 1000px;
            border: 1px solid #CDBFA8;
            background-color: #FFFFFF;
        }

        .header-table,
        .body-table {
            width: 100%;
            table-layout: fixed;
            border-collapse: collapse;
        }

        .header-table th,
        .body-table td {
            border: 1px solid #CDBFA8;
            text-align: center;
            vertical-align: middle;
            padding: 10px;
        }

        .header-table {
            border-bottom: none;
        }

        .header-table th {
            background-color: #EFE5D1;
            color: #2E4136;
            font-weight: bold;
            height: 44px;
        }

        .body-wrap {
            height: 320px;
            overflow-y: auto;
            overflow-x: hidden;
        }

        .body-table td {
            background-color: #FFFFFF;
            color: #2F2A24;
            height: 42px;
        }

        /* ヘッダーと明細の境界線が二重にならないよう調整 */
        .body-table tr:first-child td {
            border-top: none;
        }

        .col1 { width: 180px; }
        .col2 { width: 180px; }
        .col34 { width: 220px; }
        .col5 { width: 180px; }
        .col6 { width: 180px; }
    </style>
</head>
<body>

    <h1 class="page-title">分割テーブル固定見出しテスト</h1>

    <div class="table-area">

        <!-- 見出し専用テーブル -->
        <table class="header-table">
            <colgroup>
                <col class="col1">
                <col class="col2">
                <col class="col34">
                <col class="col5">
                <col class="col6">
            </colgroup>
            <thead>
                <tr>
                    <th rowspan="2">項目1</th>
                    <th rowspan="2">項目2</th>
                    <th>項目3</th>
                    <th rowspan="2">項目5</th>
                    <th rowspan="2">項目6</th>
                </tr>
                <tr>
                    <th>項目4</th>
                </tr>
            </thead>
        </table>

        <!-- 明細専用テーブル -->
        <div class="body-wrap">
            <table class="body-table">
                <colgroup>
                    <col class="col1">
                    <col class="col2">
                    <col class="col34">
                    <col class="col5">
                    <col class="col6">
                </colgroup>
                <tbody>
                    <tr>
                        <td>データ1-1</td>
                        <td>データ1-2</td>
                        <td>データ1-3 / データ1-4</td>
                        <td>データ1-5</td>
                        <td>データ1-6</td>
                    </tr>
                    <tr>
                        <td>データ2-1</td>
                        <td>データ2-2</td>
                        <td>データ2-3 / データ2-4</td>
                        <td>データ2-5</td>
                        <td>データ2-6</td>
                    </tr>
                    <tr>
                        <td>データ3-1</td>
                        <td>データ3-2</td>
                        <td>データ3-3 / データ3-4</td>
                        <td>データ3-5</td>
                        <td>データ3-6</td>
                    </tr>
                    <tr>
                        <td>データ4-1</td>
                        <td>データ4-2</td>
                        <td>データ4-3 / データ4-4</td>
                        <td>データ4-5</td>
                        <td>データ4-6</td>
                    </tr>
                    <tr>
                        <td>データ5-1</td>
                        <td>データ5-2</td>
                        <td>データ5-3 / データ5-4</td>
                        <td>データ5-5</td>
                        <td>データ5-6</td>
                    </tr>
                    <tr>
                        <td>データ6-1</td>
                        <td>データ6-2</td>
                        <td>データ6-3 / データ6-4</td>
                        <td>データ6-5</td>
                        <td>データ6-6</td>
                    </tr>
                    <tr>
                        <td>データ7-1</td>
                        <td>データ7-2</td>
                        <td>データ7-3 / データ7-4</td>
                        <td>データ7-5</td>
                        <td>データ7-6</td>
                    </tr>
                    <tr>
                        <td>データ8-1</td>
                        <td>データ8-2</td>
                        <td>データ8-3 / データ8-4</td>
                        <td>データ8-5</td>
                        <td>データ8-6</td>
                    </tr>
                    <tr>
                        <td>データ9-1</td>
                        <td>データ9-2</td>
                        <td>データ9-3 / データ9-4</td>
                        <td>データ9-5</td>
                        <td>データ9-6</td>
                    </tr>
                    <tr>
                        <td>データ10-1</td>
                        <td>データ10-2</td>
                        <td>データ10-3 / データ10-4</td>
                        <td>データ10-5</td>
                        <td>データ10-6</td>
                    </tr>
                    <tr>
                        <td>データ11-1</td>
                        <td>データ11-2</td>
                        <td>データ11-3 / データ11-4</td>
                        <td>データ11-5</td>
                        <td>データ11-6</td>
                    </tr>
                    <tr>
                        <td>データ12-1</td>
                        <td>データ12-2</td>
                        <td>データ12-3 / データ12-4</td>
                        <td>データ12-5</td>
                        <td>データ12-6</td>
                    </tr>
                    <tr>
                        <td>データ13-1</td>
                        <td>データ13-2</td>
                        <td>データ13-3 / データ13-4</td>
                        <td>データ13-5</td>
                        <td>データ13-6</td>
                    </tr>
                    <tr>
                        <td>データ14-1</td>
                        <td>データ14-2</td>
                        <td>データ14-3 / データ14-4</td>
                        <td>データ14-5</td>
                        <td>データ14-6</td>
                    </tr>
                    <tr>
                        <td>データ15-1</td>
                        <td>データ15-2</td>
                        <td>データ15-3 / データ15-4</td>
                        <td>データ15-5</td>
                        <td>データ15-6</td>
                    </tr>
                </tbody>
            </table>
        </div>

    </div>

</body>
</html>
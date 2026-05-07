<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{TITLE}}</title>
  {{STYLE_BLOCK}}
  <script>
    function toggle(targetClass) {
      var elements = document.getElementsByClassName(targetClass);
      for (var i = 0; i < elements.length; i++) {
        elements[i].style.display = elements[i].style.display === 'table-row' ? 'none' : 'table-row';
      }
    }
  </script>
</head>
<body>
  <h2>{{REPORT_TITLE}}</h2>
  <div class="meta-info"><b>Thoi gian quet:</b> {{DISPLAY_TIME}} <br/> <b>He dieu hanh:</b> {{OS_INFO}}</div>
  <table>
    <tr>
      <th rowspan="2">Description</th>
      <th colspan="2">Tests</th>
      <th colspan="2">Scoring</th>
    </tr>
    <tr>
      <th>Pass</th>
      <th>Fail</th>
      <th>Max</th>
      <th>Percent</th>
    </tr>
    {{TABLE_ROWS}}
  </table>
</body>
</html>

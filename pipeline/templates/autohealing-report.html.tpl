<!DOCTYPE html>
<html>
<head>
  <meta charset="UTF-8">
  <title>{{TITLE}}</title>
  {{STYLE_BLOCK}}
</head>
<body>
  <h2>{{REPORT_TITLE}}</h2>
  <div class='meta-info'><b>Time:</b> {{DISPLAY_TIME}} &nbsp;|&nbsp; <b>OS:</b> {{OS_INFO}}</div>
  <div class='alert-box'>DETECTED AND ATTEMPTED TO RECOVER {{DRIFTED_COUNT}} DRIFTED POLICIES</div>
  <table>
    <thead>
      <tr>
        <th>CIS ID</th>
        <th>Description</th>
        <th style='text-align: left;'>Before (Drifted Value)</th>
        <th style='text-align: left;'>After (Restored Value)</th>
        <th>Healing Status</th>
      </tr>
    </thead>
    <tbody>
      {{TABLE_ROWS}}
    </tbody>
  </table>
</body>
</html>

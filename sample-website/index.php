<?php
$serverName = "tcp:qclug-db-1.database.windows.net,1433";
$connectionOptions = array(
    "database" => "qclug-demo",
    "uid" => "tux",
    "pwd" => ""
);

// Establishes the connection
$conn = sqlsrv_connect($serverName, $connectionOptions);
if ($conn === false) {
    die(formatErrors(sqlsrv_errors()));
}

echo '
<html>
  <body>
    <table>
      <tr>';
        // Select Query
        $tsql = "SELECT COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'customer'";
        // Executes the query
        $stmt = sqlsrv_query($conn, $tsql);
        // Error handling
        if ($stmt === false) {
            die(formatErrors(sqlsrv_errors()));
        }

        $headers = array();

        while ( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) )
        {
        echo '<th>';
        echo $row['COLUMN_NAME'];
        array_push($headers, $row['COLUMN_NAME']);
        echo '<th>';
        }
        echo '
            </tr>
        ';
        // Select Query
        $tsql = "SELECT * FROM SalesLT.Customer where CustomerID < 15";
        // Executes the query
        $stmt = sqlsrv_query($conn, $tsql);
        // Error handling
        if ($stmt === false) {
            die(formatErrors(sqlsrv_errors()));
        }

        while ( $row = sqlsrv_fetch_array($stmt, SQLSRV_FETCH_ASSOC) )
        {
        echo '<tr>';
        for ($i = 0; $i<count($row); $i++)
        {
            echo '<td>';
            if (is_string($row[$headers[$i]])){ echo $row[$headers[$i]]; }
            echo '</td>';
        }
        echo '</tr>';
        }
        echo '
    </table>
  </body>
</html>';
?>

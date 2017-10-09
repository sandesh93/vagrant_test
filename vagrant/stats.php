<?php

function printDetails($status){

echo "<table border='1'>";

        echo "<tr><td>Memcache Version:</td><td> ".$status ["version"]."</td></tr>";
        echo "<tr><td>PID: </td><td>".$status ["pid"]."</td></tr>";
        echo "<tr><td>UPTIME in seconds</td><td>".$status ["uptime"]."</td></tr>";
        echo "<tr><td>current connection: </td><td>".$status ["curr_connections"]."</td></tr>";
        echo "<tr><td>Total number of connections opened since the server started running </td><td>".$status ["total_connections"]."</td></tr>";
        $percCacheHit=((real)$status ["get_hits"]/ (real)$status ["cmd_get"] *100);
        $percCacheHit=round($percCacheHit,3);
        $percCacheMiss=100-$percCacheHit;

        echo "<tr><td>GET hits in %: </td><td>".$status ["get_hits"]." ($percCacheHit%)</td></tr>";
        echo "<tr><td>GET missed in %: </td><td>".$status ["get_misses"]."($percCacheMiss%)</td></tr>";

echo "</table>";

    }
 $memcache_obj = new Memcache;
  $memcache_obj->addServer('127.0.0.1', 11211);
   printDetails($memcache_obj->getStats());
?>
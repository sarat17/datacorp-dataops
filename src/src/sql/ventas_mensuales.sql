   SELECT tienda_id, SUM(monto) AS total_mes
   FROM ventas
   GROUP BY tienda_id;

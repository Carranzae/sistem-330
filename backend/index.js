const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const bodyParser = require('body-parser');
const cors = require('cors');

// Configuración de Supabase
const supabaseUrl = 'https://<TU_SUPABASE_URL>';
const supabaseKey = '<TU_SUPABASE_ANON_KEY>';
const supabase = createClient(supabaseUrl, supabaseKey);

// Configuración de Express
const app = express();
app.use(cors());
app.use(bodyParser.json());

// Rutas
app.get('/api/businesses', async (req, res) => {
  const { data, error } = await supabase.from('negocios').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/businesses', async (req, res) => {
  const { nombre_comercial, ruc, pais, direccion_completa, rubro, modelo_negocio, configuracion, modulos_activos } = req.body;

  const { data, error } = await supabase.from('negocios').insert([
    {
      nombre_comercial,
      ruc,
      pais,
      direccion_completa,
      rubro,
      modelo_negocio,
      configuracion,
      modulos_activos,
    },
  ]);

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

app.get('/api/products', async (req, res) => {
  const { data, error } = await supabase.from('productos').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/products', async (req, res) => {
  const { nombre, precio, stock, atributos } = req.body;

  const { data, error } = await supabase.from('productos').insert([
    {
      nombre,
      precio,
      stock,
      atributos,
    },
  ]);

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

// Rutas para ventas
app.get('/api/sales', async (req, res) => {
  const { data, error } = await supabase.from('ventas').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/sales', async (req, res) => {
  const { cliente_id, productos, total, metodo_pago } = req.body;

  const { data, error } = await supabase.from('ventas').insert([
    {
      cliente_id,
      productos,
      total,
      metodo_pago,
    },
  ]);

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

// Rutas para clientes
app.get('/api/clients', async (req, res) => {
  const { data, error } = await supabase.from('clientes').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/clients', async (req, res) => {
  const { nombre_completo, tipo_documento, numero_documento, telefono, email, direccion } = req.body;

  const { data, error } = await supabase.from('clientes').insert([
    {
      nombre_completo,
      tipo_documento,
      numero_documento,
      telefono,
      email,
      direccion,
    },
  ]);

  if (error) return res.status(500).json({ error: error.message });
  res.status(201).json(data);
});

// Middleware para manejar errores
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).send('Algo salió mal!');
});

// Puerto
const PORT = 3000;
app.listen(PORT, () => {
  console.log(`Servidor corriendo en http://localhost:${PORT}`);
});

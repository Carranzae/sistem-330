require('dotenv').config();
const express = require('express');
const { createClient } = require('@supabase/supabase-js');
const bodyParser = require('body-parser');
const cors = require('cors');

// Configuración de Supabase
const supabaseUrl = process.env.SUPABASE_URL || 'https://placeholder.supabase.co';
const supabaseKey = process.env.SUPABASE_ANON_KEY || 'placeholder-key';

// Validar que las credenciales no sean placeholders
if (supabaseUrl.includes('<') || supabaseUrl.includes('placeholder') || 
    supabaseKey.includes('<') || supabaseKey.includes('placeholder')) {
  console.warn('⚠️  ADVERTENCIA: Configuración de Supabase no válida');
  console.warn('📝 Crea un archivo .env en el directorio backend/ con:');
  console.warn('   SUPABASE_URL=https://tu-proyecto.supabase.co');
  console.warn('   SUPABASE_ANON_KEY=tu-anon-key');
  console.warn('');
  console.warn('El servidor se iniciará pero las funciones de Supabase no funcionarán.');
}

// Crear cliente de Supabase con validación
let supabase;
try {
  supabase = createClient(supabaseUrl, supabaseKey);
} catch (error) {
  console.error('❌ Error al crear cliente de Supabase:', error.message);
  console.warn('⚠️  Continuando sin Supabase - algunas funciones estarán limitadas');
  supabase = null;
}

// Configuración de Express
const app = express();
app.use(cors());
app.use(bodyParser.json());

// Función helper para verificar Supabase
const checkSupabase = (res) => {
  if (!supabase) {
    return res.status(503).json({ 
      error: 'Supabase no configurado. Crea un archivo .env con SUPABASE_URL y SUPABASE_ANON_KEY' 
    });
  }
  return null;
};

// Ruta de estado del servidor
app.get('/api/health', (req, res) => {
  res.json({ 
    status: 'ok', 
    supabase: supabase ? 'configurado' : 'no configurado',
    timestamp: new Date().toISOString()
  });
});

// Ruta para Chrome DevTools (evita warning 404)
app.get('/.well-known/appspecific/com.chrome.devtools.json', (req, res) => {
  res.status(404).json({ error: 'Not found' });
});

// Rutas
app.get('/api/businesses', async (req, res) => {
  const check = checkSupabase(res);
  if (check) return check;
  
  const { data, error } = await supabase.from('negocios').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/businesses', async (req, res) => {
  const check = checkSupabase(res);
  if (check) return check;
  
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
  const check = checkSupabase(res);
  if (check) return check;
  
  const { data, error } = await supabase.from('productos').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/products', async (req, res) => {
  const check = checkSupabase(res);
  if (check) return check;
  
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
  const check = checkSupabase(res);
  if (check) return check;
  
  const { data, error } = await supabase.from('ventas').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/sales', async (req, res) => {
  const check = checkSupabase(res);
  if (check) return check;
  
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
  const check = checkSupabase(res);
  if (check) return check;
  
  const { data, error } = await supabase.from('clientes').select('*');
  if (error) return res.status(500).json({ error: error.message });
  res.json(data);
});

app.post('/api/clients', async (req, res) => {
  const check = checkSupabase(res);
  if (check) return check;
  
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
const PORT = process.env.PORT || 3000;

app.listen(PORT, () => {
  console.log('');
  console.log('✅ Servidor corriendo en http://localhost:' + PORT);
  console.log('📊 Estado: http://localhost:' + PORT + '/api/health');
  if (!supabase) {
    console.log('⚠️  ADVERTENCIA: Supabase no configurado');
  }
  console.log('');
}).on('error', (err) => {
  if (err.code === 'EADDRINUSE') {
    console.error('');
    console.error('❌ Error: El puerto ' + PORT + ' ya está en uso');
    console.error('');
    console.error('💡 Soluciones:');
    console.error('   1. Cierra el proceso que usa el puerto ' + PORT);
    console.error('   2. O cambia el puerto: PORT=3001 npm run dev');
    console.error('   3. O ejecuta: Get-Process -Name node | Stop-Process');
    console.error('');
    process.exit(1);
  } else {
    throw err;
  }
});

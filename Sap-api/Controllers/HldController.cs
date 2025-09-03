using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sap_api.Models;

namespace Sap_api.Controllers
{
    [Route("api/[controller]")]
    [ApiController]
    public class Hld1sController : ControllerBase
    {
        // Reemplaza 'YourDbContext' con el nombre de tu clase de contexto de base de datos
        private readonly ApplicationDbContext _context;

        public Hld1sController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Hld1s
        // Obtiene todos los registros de HLD1
        [HttpGet]
        public async Task<ActionResult<IEnumerable<Hld1>>> GetHld1s()
        {
            if (_context.Hld1s == null)
            {
                return NotFound("La entidad 'Hld1s' no está configurada en el DbContext.");
            }
            return await _context.Hld1s.ToListAsync();
        }

        // GET: api/Hld1s/{HldCode}/{StrDate}/{EndDate}
        // Obtiene un registro específico por su clave compuesta
        // Nota: Las fechas en el URL deben estar en formato ISO 8601 (ej: 2025-12-31T23:59:59)
        [HttpGet("{hldCode}/{strDate}/{endDate}")]
        public async Task<ActionResult<Hld1>> GetHld1(string hldCode, DateTime strDate, DateTime endDate)
        {
            if (_context.Hld1s == null)
            {
                return NotFound();
            }
            // Usamos FindAsync para buscar por clave primaria (compuesta en este caso)
            var hld1 = await _context.Hld1s.FindAsync(hldCode, strDate, endDate);

            if (hld1 == null)
            {
                return NotFound("No se encontró el registro con la clave especificada.");
            }

            return hld1;
        }

        // PUT: api/Hld1s/{HldCode}/{StrDate}/{EndDate}
        // Actualiza un registro existente
        [HttpPut("{hldCode}/{strDate}/{endDate}")]
        public async Task<IActionResult> PutHld1(string hldCode, DateTime strDate, DateTime endDate, Hld1 hld1)
        {
            // Valida que la clave en la URL coincida con la clave en el cuerpo
            if (hldCode != hld1.HldCode || strDate != hld1.StrDate || endDate != hld1.EndDate)
            {
                return BadRequest("La clave compuesta del URL no coincide con la del cuerpo de la solicitud.");
            }

            _context.Entry(hld1).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!Hld1Exists(hldCode, strDate, endDate))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent();
        }

        // POST: api/Hld1s
        // Crea un nuevo registro
        [HttpPost]
        public async Task<ActionResult<Hld1>> PostHld1(Hld1 hld1)
        {
            if (_context.Hld1s == null)
            {
                return Problem("La entidad 'Hld1s' no está configurada en el DbContext.");
            }

            // Opcional: Verificar si ya existe el registro
            if (Hld1Exists(hld1.HldCode, hld1.StrDate, hld1.EndDate))
            {
                return Conflict("Ya existe un registro con esa clave compuesta.");
            }

            _context.Hld1s.Add(hld1);
            await _context.SaveChangesAsync();

            // Retorna una respuesta 201 Created con la ubicación del nuevo recurso
            return CreatedAtAction("GetHld1", new { hldCode = hld1.HldCode, strDate = hld1.StrDate, endDate = hld1.EndDate }, hld1);
        }

        // DELETE: api/Hld1s/{HldCode}/{StrDate}/{EndDate}
        // Elimina un registro por su clave compuesta
        [HttpDelete("{hldCode}/{strDate}/{endDate}")]
        public async Task<IActionResult> DeleteHld1(string hldCode, DateTime strDate, DateTime endDate)
        {
            if (_context.Hld1s == null)
            {
                return NotFound();
            }

            var hld1 = await _context.Hld1s.FindAsync(hldCode, strDate, endDate);
            if (hld1 == null)
            {
                return NotFound();
            }

            _context.Hld1s.Remove(hld1);
            await _context.SaveChangesAsync();

            return NoContent();
        }

        // Método privado para verificar si un registro existe usando la clave compuesta
        private bool Hld1Exists(string hldCode, DateTime strDate, DateTime endDate)
        {
            return (_context.Hld1s?.Any(e => e.HldCode == hldCode && e.StrDate == strDate && e.EndDate == endDate)).GetValueOrDefault();
        }
    }

}

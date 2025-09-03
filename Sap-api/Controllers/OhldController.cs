using Dtos.OHLD;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Sap_api.Models;

namespace Sap_api.Controllers
{

    [Route("api/[controller]")]
    [ApiController]
    public class OhldsController : ControllerBase
    {
        // Reemplaza 'YourDbContext' con el nombre de tu clase de contexto de base de datos
        private readonly ApplicationDbContext _context;

        public OhldsController(ApplicationDbContext context)
        {
            _context = context;
        }

        // GET: api/Ohlds
        // Obtiene todos los registros de OHLD
        [HttpGet]
        public async Task<ActionResult<OhldDTO>> GetOhlds()
        {
            if (_context.Ohlds == null)
            {
                return NotFound("La entidad 'Ohlds' no está configurada en el DbContext.");
            }
            var ohlds = await _context.Ohlds
                .Include(o => o.Hld1s) // Incluye los registros relacionados de Hld1
                .ToListAsync();

            var data = ohlds.Select(o => new OhldDTO
            {
                HldCode = o.HldCode,
                WndFrm = o.WndFrm,
                WndTo = o.WndTo,
                IsCurYear = o.IsCurYear,
                IgnrWnd = o.IgnrWnd,
                WeekNoRule = o.WeekNoRule,
                Hld1s = o.Hld1s.Select(h => new DetailedOhldDTO
                {
                    HldCode = h.HldCode,
                    StrDate = h.StrDate,
                    EndDate = h.EndDate,
                    Rmrks = h.Rmrks

                }).ToList()
            }).ToList();

            return Ok(data);
        }

        // GET: api/Ohlds/5
        // Obtiene un registro específico de OHLD por su HldCode
        [HttpGet("{id}")]
        public async Task<ActionResult<Ohld>> GetOhld(string id)
        {
            if (_context.Ohlds == null)
            {
                return NotFound();
            }
            var ohld = await _context.Ohlds.FindAsync(id);

            if (ohld == null)
            {
                return NotFound($"No se encontró ningún registro con el HldCode: {id}");
            }

            return ohld;
        }

        // PUT: api/Ohlds/5
        // Actualiza un registro existente.
        [HttpPut("{id}")]
        public async Task<IActionResult> PutOhld(string id, Ohld ohld)
        {
            if (id != ohld.HldCode)
            {
                return BadRequest("El 'HldCode' del URL no coincide con el del cuerpo de la solicitud.");
            }

            _context.Entry(ohld).State = EntityState.Modified;

            try
            {
                await _context.SaveChangesAsync();
            }
            catch (DbUpdateConcurrencyException)
            {
                if (!OhldExists(id))
                {
                    return NotFound();
                }
                else
                {
                    throw;
                }
            }

            return NoContent(); // Respuesta estándar para una actualización exitosa
        }

        // POST: api/Ohlds
        // Crea un nuevo registro en OHLD
        [HttpPost]
        public async Task<ActionResult<Ohld>> PostOhld(Ohld ohld)
        {
            if (_context.Ohlds == null)
            {
                return Problem("La entidad 'Ohlds' no está configurada en el DbContext.");
            }

            // Opcional: Verificar si ya existe para evitar errores de clave primaria
            if (OhldExists(ohld.HldCode))
            {
                return Conflict($"Ya existe un registro con el HldCode: {ohld.HldCode}");
            }

            _context.Ohlds.Add(ohld);
            await _context.SaveChangesAsync();

            // Retorna una respuesta 201 Created con la ubicación del nuevo recurso
            return CreatedAtAction("GetOhld", new { id = ohld.HldCode }, ohld);
        }

        // DELETE: api/Ohlds/5
        // Elimina un registro de OHLD
        [HttpDelete("{id}")]
        public async Task<IActionResult> DeleteOhld(string id)
        {
            if (_context.Ohlds == null)
            {
                return NotFound();
            }
            var ohld = await _context.Ohlds.FindAsync(id);
            if (ohld == null)
            {
                return NotFound();
            }

            _context.Ohlds.Remove(ohld);
            await _context.SaveChangesAsync();

            return NoContent(); // Respuesta estándar para una eliminación exitosa
        }

        // Método privado para verificar si un registro existe
        private bool OhldExists(string id)
        {
            return (_context.Ohlds?.Any(e => e.HldCode == id)).GetValueOrDefault();
        }
    }


}

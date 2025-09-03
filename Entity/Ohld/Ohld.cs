using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace Sap_api.Models;

[Table("OHLD")]
public partial class Ohld
{

    public Ohld()
    {
        // Inicializar la colección para evitar errores de referencia nula.
        Hld1s = new HashSet<Hld1>();
    }

    [Key]
    [StringLength(20)]
    public string HldCode { get; set; } = null!;

    [StringLength(1)]
    public string? WndFrm { get; set; }

    [StringLength(1)]
    public string? WndTo { get; set; }

    [Column("isCurYear")]
    [StringLength(1)]
    public string? IsCurYear { get; set; }

    [Column("ignrWnd")]
    [StringLength(1)]
    public string? IgnrWnd { get; set; }

    [StringLength(1)]
    public string? WeekNoRule { get; set; }

    public virtual ICollection<Hld1> Hld1s { get; set; }

}

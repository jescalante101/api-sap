using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;
using Microsoft.EntityFrameworkCore;

namespace Sap_api.Models;

[PrimaryKey("HldCode", "StrDate", "EndDate")]
[Table("HLD1")]
public partial class Hld1
{
    [Key]
    [StringLength(20)]
    public string HldCode { get; set; } = null!;

    [Key]
    [Column(TypeName = "datetime")]
    public DateTime StrDate { get; set; }

    [Key]
    [Column(TypeName = "datetime")]
    public DateTime EndDate { get; set; }

    [StringLength(50)]
    public string? Rmrks { get; set; }

    [ForeignKey("HldCode")]
    public virtual Ohld Ohld { get; set; } = null!;
}

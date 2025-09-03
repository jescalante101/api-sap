using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations.Schema;
using System.ComponentModel.DataAnnotations;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Dtos.OHLD
{
    public class OhldDTO
    {
        public string HldCode { get; set; } = null!;
        public string? WndFrm { get; set; }
        public string? WndTo { get; set; }
        public string? IsCurYear { get; set; }
        public string? IgnrWnd { get; set; }
        public string? WeekNoRule { get; set; }
        
        public ICollection<DetailedOhldDTO> Hld1s { get; set; } = new List<DetailedOhldDTO>();

    }

    public class DetailedOhldDTO 
    {
        public string HldCode { get; set; } = null!;
        public DateTime StrDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? Rmrks { get; set; }
    }

}

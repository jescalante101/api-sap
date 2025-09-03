using Microsoft.EntityFrameworkCore;
using Sap_api.Models; // Asegúrate de que este namespace sea correcto
public partial class ApplicationDbContext : DbContext
{
    public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options)
        : base(options)
    {
    }

    public virtual DbSet<Hld1> Hld1s { get; set; }
    public virtual DbSet<Ohld> Ohlds { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        modelBuilder.UseCollation("SQL_Latin1_General_CP850_CI_AS");

        modelBuilder.Entity<Hld1>(entity =>
        {
            // Se mantiene la definición de la clave compuesta
            entity.HasKey(e => new { e.HldCode, e.StrDate, e.EndDate }).HasName("HLD1_PRIMARY");

            // --- CORRECCIÓN AÑADIDA ---
            // Aquí se define la relación explícitamente.
            // Le decimos a EF que Hld1 tiene un Ohld padre, y que un Ohld tiene muchos Hld1s hijos.
            entity.HasOne(d => d.Ohld)
                  .WithMany(p => p.Hld1s)
                  .HasForeignKey(d => d.HldCode)
                  .OnDelete(DeleteBehavior.Cascade) // Comportamiento al borrar (opcional)
                  .HasConstraintName("FK_HLD1_OHLD"); // Nombre de la restricción (opcional)
        });

        modelBuilder.Entity<Ohld>(entity =>
        {
            // Se mantienen tus configuraciones
            entity.HasKey(e => e.HldCode).HasName("OHLD_PRIMARY");
            entity.Property(e => e.IgnrWnd).IsFixedLength();
            entity.Property(e => e.IsCurYear).IsFixedLength();
            entity.Property(e => e.WeekNoRule).IsFixedLength();
            entity.Property(e => e.WndFrm).IsFixedLength();
            entity.Property(e => e.WndTo).IsFixedLength();
        });

        OnModelCreatingPartial(modelBuilder);
    }

    partial void OnModelCreatingPartial(ModelBuilder modelBuilder);
}

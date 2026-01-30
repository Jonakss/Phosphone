/* * ~PHOSPHOR KERNEL: MEMORY SWEEPER (DEBUG MODE)
 * ===============================================
 * Target: Samsung SM-T110 (Frozen Logo Fix)
 * Strategy: Blindly write to common RAM regions to find the Framebuffer.
 */

#include <stdint.h>

#define SCREEN_W 1024
#define SCREEN_H 600

// Definimos varias zonas posibles donde Samsung suele poner el video en estos chips
// 0x10000000: Inicio RAM usuario
// 0x20000000: Mitad RAM
// 0x30000000: Alta RAM
// 0x3F000000: Final de RAM (Muy común para Framebuffers reservados)
uint32_t candidate_addrs[] = {
    0x10000000, 
    0x1C000000,
    0x20000000, 
    0x30000000,
    0x3F000000, // Candidato fuerte
    0x40000000
};

typedef uint32_t Pixel; 

// --- PATRÓN VISUAL AGRESIVO ---
void k_paint_zone(volatile Pixel* fb, int tick, int zone_id) {
    // Pintamos solo una franja para no colgar el bus si la memoria no existe
    for(int i = 0; i < SCREEN_W * 100; i++) { 
        // Color estroboscópico: Cambia entre Rojo y Azul según el tick
        uint32_t color = (tick % 2) ? 0xFFFF0000 : 0xFF0000FF; 
        
        // Agregamos el ID de zona en verde para saber cuál funcionó
        color |= (zone_id * 40) << 8; 
        
        fb[i] = color;
    }
}

void kmain(void) {
    // NO reconfiguramos el LCD. Usamos la config que dejó el Bootloader.
    // Solo buscamos dónde está leyendo.
    
    int tick = 0;
    while(1) {
        // Barrido: Intentamos escribir en todas las direcciones candidatas
        for(int i=0; i < 6; i++) {
            volatile Pixel* try_vram = (volatile Pixel*)candidate_addrs[i];
            k_paint_zone(try_vram, tick, i+1);
        }
        
        tick++;
        
        // Delay visible (Strobe effect)
        for(volatile int d=0; d<500000; d++);
    }
}
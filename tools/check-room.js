#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

// Required layers that must exist in each room JSON file
const REQUIRED_LAYERS = [
    'collision',
    'spawn_player', 
    'spawn_enemies',
    'hazards',
    'doors'
];

/**
 * Validates a room JSON file for required layers
 * @param {string} filePath - Path to the JSON file to validate
 * @returns {boolean} - true if valid, false if invalid
 */
function validateRoomFile(filePath) {
    try {
        // Read and parse the JSON file
        const fileContent = fs.readFileSync(filePath, 'utf8');
        const roomData = JSON.parse(fileContent);
        
        // Check if the file has the expected structure
        if (!roomData.layers || !Array.isArray(roomData.layers)) {
            console.error(`❌ Invalid room file structure in ${filePath}: missing or invalid 'layers' array`);
            return false;
        }
        
        // Get all layer names from the file
        const layerNames = roomData.layers.map(layer => layer.name);
        
        // Check for each required layer
        let isValid = true;
        for (const requiredLayer of REQUIRED_LAYERS) {
            if (!layerNames.includes(requiredLayer)) {
                console.error(`❌ Missing layer '${requiredLayer}' in ${filePath}`);
                isValid = false;
            }
        }
        
        if (isValid) {
            console.log(`✅ ${filePath} OK`);
        }
        
        return isValid;
        
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error(`❌ File not found: ${filePath}`);
        } else if (error instanceof SyntaxError) {
            console.error(`❌ Invalid JSON in ${filePath}: ${error.message}`);
        } else {
            console.error(`❌ Error reading ${filePath}: ${error.message}`);
        }
        return false;
    }
}

/**
 * Main function to process command line arguments
 */
function main() {
    const args = process.argv.slice(2);
    
    if (args.length === 0) {
        console.error('Usage: node check-room.js <room-file1> [room-file2] ...');
        console.error('Example: node check-room.js game-godot/data/rooms/A1.json');
        process.exit(1);
    }
    
    let allValid = true;
    
    // Process each file passed as an argument
    for (const filePath of args) {
        // Convert to absolute path for better error messages
        const absolutePath = path.resolve(filePath);
        
        if (!validateRoomFile(absolutePath)) {
            allValid = false;
        }
    }
    
    // Exit with appropriate code
    if (allValid) {
        process.exit(0);
    } else {
        process.exit(1);
    }
}

// Run the main function
main();


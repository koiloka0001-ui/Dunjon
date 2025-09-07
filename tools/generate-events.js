#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

/**
 * Converts a snake_case string to SCREAMING_SNAKE_CASE
 * @param {string} str - The string to convert
 * @returns {string} - The converted string
 */
function toScreamingSnakeCase(str) {
    return str.toUpperCase();
}

/**
 * Generates the Events.gd file content from events.json
 * @param {Object} eventsData - The parsed events.json data
 * @returns {string} - The generated GDScript content
 */
function generateEventsGd(eventsData) {
    const eventKeys = Object.keys(eventsData);
    
    let content = '# Auto-generated from tools/events.json. Do not edit.\n\n';
    content += 'class_name Events\n\n';
    
    // Generate constants for each event
    for (const eventKey of eventKeys) {
        const constantName = toScreamingSnakeCase(eventKey);
        content += `const ${constantName} = "${eventKey}"\n`;
    }
    
    return content;
}

/**
 * Main function to generate Events.gd from events.json
 */
function main() {
    try {
        // Read and parse events.json
        const eventsJsonPath = path.join(__dirname, 'events.json');
        const eventsJsonContent = fs.readFileSync(eventsJsonPath, 'utf8').replace(/^\uFEFF/, ''); // Remove BOM if present
        const eventsData = JSON.parse(eventsJsonContent);
        
        // Generate the Events.gd content
        const eventsGdContent = generateEventsGd(eventsData);
        
        // Write to autoload/Events.gd
        const eventsGdPath = path.join(__dirname, '..', 'game-godot', 'autoload', 'Events.gd');
        fs.writeFileSync(eventsGdPath, eventsGdContent, 'utf8');
        
        console.log('✅ Generated autoload/Events.gd successfully');
        console.log(`   Generated ${Object.keys(eventsData).length} event constants`);
        
    } catch (error) {
        if (error.code === 'ENOENT') {
            console.error('❌ File not found: tools/events.json');
        } else if (error instanceof SyntaxError) {
            console.error('❌ Invalid JSON in tools/events.json:', error.message);
        } else {
            console.error('❌ Error:', error.message);
        }
        process.exit(1);
    }
}

// Run the main function
main();
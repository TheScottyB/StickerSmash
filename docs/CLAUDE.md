# StickerSmash - Development Guidelines

## Commands
- `npx expo start` - Start the development server
- `npm run ios` - Start on iOS simulator
- `npm run android` - Start on Android emulator
- `npm run web` - Start web version
- `npm test` - Run all tests with Jest in watch mode
- `npm run lint` - Run ESLint

## Code Style Guidelines
- **Imports**: React first, then libraries, then local imports
- **TypeScript**: Use strict typing for all components, props, state, and functions
- **Components**: Use functional components with hooks
- **Naming**: PascalCase for components/types, camelCase for functions/variables, UPPERCASE for constants
- **State Management**: Use React hooks (useState, useRef) for component state
- **Error Handling**: Use try/catch with user-friendly Alert messages
- **Styling**: StyleSheet.create() at bottom of file, consistent naming
- **Formatting**: 2-space indentation, JSX props on new lines when multiple
- **Comments**: Add comments for complex logic and component sections

## File Organization
- Components go in `/components` directory
- Main app screens in `/app` directory using Expo Router
- Reusable hooks in `/hooks` directory (when created)

## Recent Improvements (April 2025)
- Added memory management with automatic cleanup of temporary files
- Implemented comprehensive permission handling (including limited permissions)
- Added image size checks with automatic compression for large images
- Added error boundary for crash protection
- Improved sticker position constraints to prevent stickers going out of bounds
- Prevented race conditions in async operations
- Added visual feedback during processing operations (disabled buttons, loading text)
- Better cleanup of resources when component unmounts
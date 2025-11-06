import { createTheme } from '@mui/material/styles';

// Define a custom dark theme inspired by the Flutter app's aesthetic
const darkTheme = createTheme({
  palette: {
    mode: 'dark',
    primary: {
      main: '#00bcd4', // Teal-like color, common in Flutter apps
    },
    secondary: {
      main: '#ff4081', // Pink accent
    },
    background: {
      default: '#121212', // Dark background
      paper: '#1e1e1e', // Slightly lighter dark for cards/surfaces
    },
    text: {
      primary: '#ffffff', // White text
      secondary: '#b0b0b0', // Lighter grey for secondary text
    },
  },
  typography: {
    fontFamily: 'Roboto, Arial, sans-serif',
    h1: { fontSize: '2.5rem' },
    h2: { fontSize: '2rem' },
    h3: { fontSize: '1.75rem' },
    h4: { fontSize: '1.5rem' },
    h5: { fontSize: '1.25rem' },
    h6: { fontSize: '1rem' },
  },
  components: {
    MuiAppBar: {
      styleOverrides: {
        root: {
          backgroundColor: '#1e1e1e',
        },
      },
    },
    MuiDrawer: {
      styleOverrides: {
        paper: {
          backgroundColor: '#1e1e1e',
        },
      },
    },
    MuiCard: {
      styleOverrides: {
        root: {
          backgroundColor: '#1e1e1e',
          boxShadow: '0px 2px 10px rgba(0, 0, 0, 0.5)',
        },
      },
    },
    MuiButton: {
      styleOverrides: {
        root: {
          textTransform: 'none',
        },
      },
    },
  },
});

export default darkTheme;

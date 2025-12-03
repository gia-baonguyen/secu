import React from 'react';
import { BrowserRouter as Router, Routes, Route } from 'react-router-dom';
import { ThemeProvider, createTheme } from '@mui/material/styles';
import { CssBaseline, Container, Typography, Box, Paper } from '@mui/material';

// Create theme
const theme = createTheme({
  palette: {
    primary: {
      main: '#1976d2',
    },
    secondary: {
      main: '#dc004e',
    },
  },
});

// Simple Home component
function Home() {
  return (
    <Container maxWidth="md" sx={{ mt: 8 }}>
      <Paper elevation={3} sx={{ p: 4, textAlign: 'center' }}>
        <Typography variant="h3" color="primary" gutterBottom>
          Grade Management System
        </Typography>
        <Typography variant="h5" color="textSecondary" paragraph>
          University Grade Management System
        </Typography>
        <Box sx={{ mt: 4 }}>
          <Typography variant="body1" paragraph>
            Frontend: React 18.2.0 + Material-UI 5.14
          </Typography>
          <Typography variant="body1" paragraph>
            Backend: Spring Boot 3.1.5 + Oracle Database 19c
          </Typography>
          <Typography variant="body1" paragraph>
            Security: VPD (Virtual Private Database) + FGA (Fine-Grained Auditing)
          </Typography>
        </Box>
        <Box sx={{ mt: 4, p: 2, bgcolor: 'success.light', borderRadius: 2 }}>
          <Typography variant="h6" color="success.dark">
            ✅ Frontend Development Server Running Successfully!
          </Typography>
        </Box>
      </Paper>
    </Container>
  );
}

// Not Found component
function NotFound() {
  return (
    <Container maxWidth="sm" sx={{ mt: 8, textAlign: 'center' }}>
      <Typography variant="h2" color="error" gutterBottom>
        404
      </Typography>
      <Typography variant="h5" gutterBottom>
        Page Not Found
      </Typography>
      <Typography variant="body1" color="textSecondary">
        The page you are looking for does not exist yet.
      </Typography>
    </Container>
  );
}

function App() {
  return (
    <ThemeProvider theme={theme}>
      <CssBaseline />
      <Router>
        <Routes>
          <Route path="/" element={<Home />} />
          <Route path="*" element={<NotFound />} />
        </Routes>
      </Router>
    </ThemeProvider>
  );
}

export default App;
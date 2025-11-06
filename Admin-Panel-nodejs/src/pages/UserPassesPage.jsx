import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogContentText, DialogTitle, Button } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';

const UserPassesPage = () => {
  const [passes, setPasses] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [passToDelete, setPassToDelete] = useState(null);

const fetchUserPasses = () => {
    setLoading(true);
    dataService.getAll('user-passes') // Corrected endpoint
      .then(response => {
        setPasses(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch user passes:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchUserPasses();
  }, []);

  const handleDeleteClick = (id) => {
    setPassToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('user-passes', passToDelete); // Corrected endpoint
      fetchUserPasses();
      setDeleteDialogOpen(false);
      setPassToDelete(null);
    } catch (error) {
      console.error("Failed to delete user pass:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 220 },
    { field: 'user', headerName: 'User', width: 220, valueGetter: (value) => value.email },
    { field: 'pass_type', headerName: 'Pass Type', width: 180, valueGetter: (value) => value.name },
    { field: 'purchased_at', headerName: 'Purchased At', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
    { field: 'expires_at', headerName: 'Expires At', type: 'dateTime', width: 180, valueGetter: (value) => new Date(value) },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 100,
      getActions: ({ id }) => [
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Typography variant="h4" sx={{ mb: 4 }}>Manage User Passes</Typography>
      <DataGrid
        rows={passes}
        columns={columns}
        loading={loading}
        getRowId={(row) => row._id}
        initialState={{          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog
        open={deleteDialogOpen}
        onClose={() => setDeleteDialogOpen(false)}
      >
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent>
          <DialogContentText>
            Are you sure you want to delete this user pass? This action cannot be undone.
          </DialogContentText>
        </DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default UserPassesPage;
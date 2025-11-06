import React, { useState, useEffect } from 'react';
import { Box, Typography, IconButton, Dialog, DialogActions, DialogContent, DialogTitle, Button, TextField } from '@mui/material';
import { DataGrid } from '@mui/x-data-grid';
import dataService from '../services/dataService';
import DeleteIcon from '@mui/icons-material/Delete';
import EditIcon from '@mui/icons-material/Edit';
import AddIcon from '@mui/icons-material/Add';

const BikesPage = () => {
  const [bikes, setBikes] = useState([]);
  const [loading, setLoading] = useState(true);
  const [deleteDialogOpen, setDeleteDialogOpen] = useState(false);
  const [bikeToDelete, setBikeToDelete] = useState(null);
  const [formDialogOpen, setFormDialogOpen] = useState(false);
  const [currentBike, setCurrentBike] = useState(null);

  const fetchBikes = () => {
    setLoading(true);
    dataService.getAll('bikes')
      .then(response => {
        setBikes(response.data);
        setLoading(false);
      })
      .catch(error => {
        console.error("Failed to fetch bikes:", error);
        setLoading(false);
      });
  };

  useEffect(() => {
    fetchBikes();
  }, []);

  const handleOpenFormDialog = (bike = null) => {
    setCurrentBike(bike ? { ...bike } : { qr_code: '', status: 'AVAILABLE', battery_level: 100, latitude: '', longitude: '' });
    setFormDialogOpen(true);
  };

  const handleCloseFormDialog = () => {
    setFormDialogOpen(false);
    setCurrentBike(null);
  };

  const handleSave = async () => {
    try {
      if (currentBike.id) {
        await dataService.update('bikes', currentBike.id, currentBike);
      } else {
        await dataService.create('bikes', currentBike);
      }
      fetchBikes();
      handleCloseFormDialog();
    } catch (error) {
      console.error("Failed to save bike:", error);
    }
  };

  const handleDeleteClick = (id) => {
    setBikeToDelete(id);
    setDeleteDialogOpen(true);
  };

  const handleDeleteConfirm = async () => {
    try {
      await dataService.remove('bikes', bikeToDelete);
      fetchBikes();
      setDeleteDialogOpen(false);
      setBikeToDelete(null);
    } catch (error) {
      console.error("Failed to delete bike:", error);
    }
  };

  const columns = [
    { field: 'id', headerName: 'ID', width: 220 },
    { field: 'qr_code', headerName: 'QR Code', width: 200 },
    { field: 'status', headerName: 'Status', width: 120 },
    { field: 'battery_level', headerName: 'Battery', type: 'number', width: 100 },
    { field: 'latitude', headerName: 'Latitude', type: 'number', width: 120 },
    { field: 'longitude', headerName: 'Longitude', type: 'number', width: 120 },
    { field: 'last_reported_at', headerName: 'Last Reported', type: 'dateTime', width: 200, valueGetter: (value) => value ? new Date(value) : null },
    {
      field: 'actions',
      headerName: 'Actions',
      type: 'actions',
      width: 120,
      getActions: ({ id, row }) => [
        <IconButton color="primary" onClick={() => handleOpenFormDialog(row)}><EditIcon /></IconButton>,
        <IconButton color="error" onClick={() => handleDeleteClick(id)}><DeleteIcon /></IconButton>,
      ],
    },
  ];

  return (
    <Box sx={{ height: '85vh', width: '100%' }}>
      <Box sx={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', mb: 4 }}>
        <Typography variant="h4">Manage Bikes</Typography>
        <Button variant="contained" startIcon={<AddIcon />} onClick={() => handleOpenFormDialog()}>Create Bike</Button>
      </Box>
      <DataGrid
        rows={bikes}
        columns={columns}
        loading={loading}
        getRowId={(row) => row.id}
        initialState={{
          pagination: {
            paginationModel: { page: 0, pageSize: 10 },
          },
        }}
        pageSizeOptions={[5, 10, 20]}
        checkboxSelection
      />
      <Dialog open={deleteDialogOpen} onClose={() => setDeleteDialogOpen(false)}>
        <DialogTitle>Confirm Deletion</DialogTitle>
        <DialogContent><p>Are you sure you want to delete this bike?</p></DialogContent>
        <DialogActions>
          <Button onClick={() => setDeleteDialogOpen(false)}>Cancel</Button>
          <Button onClick={handleDeleteConfirm} color="error">Delete</Button>
        </DialogActions>
      </Dialog>
      <Dialog open={formDialogOpen} onClose={handleCloseFormDialog}>
        <DialogTitle>{currentBike?.id ? 'Edit Bike' : 'Create Bike'}</DialogTitle>
        <DialogContent>
            {currentBike && (
                <Box component="form" sx={{ mt: 2 }}>
                    <TextField margin="dense" label="QR Code" fullWidth value={currentBike.qr_code} onChange={(e) => setCurrentBike({ ...currentBike, qr_code: e.target.value })} />
                    <TextField margin="dense" label="Status" fullWidth value={currentBike.status} onChange={(e) => setCurrentBike({ ...currentBike, status: e.target.value })} />
                    <TextField margin="dense" label="Battery Level" type="number" fullWidth value={currentBike.battery_level} onChange={(e) => setCurrentBike({ ...currentBike, battery_level: e.target.value })} />
                    <TextField margin="dense" label="Latitude" type="number" fullWidth value={currentBike.latitude} onChange={(e) => setCurrentBike({ ...currentBike, latitude: e.target.value })} />
                    <TextField margin="dense" label="Longitude" type="number" fullWidth value={currentBike.longitude} onChange={(e) => setCurrentBike({ ...currentBike, longitude: e.target.value })} />
                </Box>
            )}
        </DialogContent>
        <DialogActions>
          <Button onClick={handleCloseFormDialog}>Cancel</Button>
          <Button onClick={handleSave}>Save</Button>
        </DialogActions>
      </Dialog>
    </Box>
  );
};

export default BikesPage;

